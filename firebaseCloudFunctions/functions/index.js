const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.updateUser = functions.firestore
    .document('users/{userId}')
    .onUpdate((change, context) => {
      // Get an object representing the document
      // e.g. {'name': 'Marie', 'age': 66}
      const newValue = change.after.data();

      // ...or the previous value before this update
      const previousValue = change.before.data();

      // access a particular field as you would any JS property

      var delta = Math.max(
        (newValue.appLaunchesCount || 0) - (previousValue.appLaunchesCount || 0),
        (newValue.inviteesLaunchCount || 0) - (previousValue.inviteesLaunchCount || 0),
        0
         );//

         if(delta === 0){
           console.log('somehow, delta is 0');
           return 0;
         }
      //console.log('inviter', newValue.inviter);

      var inviterRef = newValue.inviter; //firestore.doc('users/doc');

      if(inviterRef){
        inviterRef.get().then(function (inviterSnapshot) {
          if (inviterSnapshot.exists) {
            inviterRef.update({inviteesLaunchCount: ((inviterSnapshot.data().inviteesLaunchCount || 0) + delta)});
          }
          return;
        }).catch(function(error){
          console.log('error', error);
        });
      }


return 0;
      // perform desired operations ...
    });


    // exports.detectLoop = functions.firestore
    //     .document('users/{userId}')
    //     .onUpdate((change, context) => {
    //       // Get an object representing the document
    //       // e.g. {'name': 'Marie', 'age': 66}
    //       const newValue = change.after.data();
    //       const previousValue = change.before.data();
    //
    //       if(newValue.inviter !== previousValue.inviter){
    //         console.log('should check for loop');
    //       }else{
    //         console.log('same inviter');
    //       }
    //       return 0;
    //       // perform desired operations ...
    //     });
