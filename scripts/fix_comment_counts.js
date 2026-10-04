// Run this script with: node scripts/fix_comment_counts.js
// Make sure you have firebase-admin installed: npm install firebase-admin

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json'); // You'll need to download this from Firebase

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function fixCommentCounts() {
  console.log('Starting comment count fix...');
  
  try {
    // Get all posts
    const postsSnapshot = await db.collection('communityPosts').get();
    
    for (const postDoc of postsSnapshot.docs) {
      const postId = postDoc.id;
      const postData = postDoc.data();
      
      // Count actual comments for this post
      const commentsSnapshot = await db.collection('postComments')
        .where('postId', '==', postId)
        .get();
      
      const actualCount = commentsSnapshot.size;
      const storedCount = postData.commentCount || 0;
      
      if (actualCount !== storedCount) {
        console.log(`Post ${postId}: stored count=${storedCount}, actual count=${actualCount}`);
        
        // Update the post with correct count
        await postDoc.ref.update({
          commentCount: actualCount
        });
        
        console.log(`  ? Updated to ${actualCount}`);
      }
    }
    
    console.log('Comment count fix completed!');
  } catch (error) {
    console.error('Error fixing comment counts:', error);
  }
}

async function removeDuplicateComments() {
  console.log('Checking for duplicate comments...');
  
  try {
    // Get all comments
    const commentsSnapshot = await db.collection('postComments').get();
    
    // Group by content, author, and post
    const commentGroups = new Map();
    
    for (const commentDoc of commentsSnapshot.docs) {
      const data = commentDoc.data();
      const key = `${data.postId}_${data.authorId}_${data.content}_${Math.floor(data.createdAt.toMillis() / 60000)}`; // Group by minute
      
      if (!commentGroups.has(key)) {
        commentGroups.set(key, []);
      }
      commentGroups.get(key).push({ id: commentDoc.id, data });
    }
    
    // Find and delete duplicates
    let deletedCount = 0;
    for (const [key, comments] of commentGroups) {
      if (comments.length > 1) {
        console.log(`Found ${comments.length} duplicate comments:`, comments[0].data.content.substring(0, 50));
        
        // Keep the first one, delete the rest
        for (let i = 1; i < comments.length; i++) {
          await db.collection('postComments').doc(comments[i].id).delete();
          deletedCount++;
          console.log(`  ? Deleted duplicate ${comments[i].id}`);
        }
      }
    }
    
    console.log(`Removed ${deletedCount} duplicate comments`);
  } catch (error) {
    console.error('Error removing duplicates:', error);
  }
}

async function main() {
  await removeDuplicateComments();
  await fixCommentCounts();
  process.exit(0);
}

main();
