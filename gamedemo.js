/*

if (Meteor.isClient) {
  /*Session.set('playerID', null);

  Template.newPlayer.events = {
    'click button' : function () {
      // template data, if any, is available in 'this'
      if (typeof console !== 'undefined')
        console.log("You pressed the button");
      if ($('#nameInput').val().length < 3)
        console.log("Name must be 3 or more characters.");
      if (Players.findOne({name: $('#nameInput').val()}))
        console.log("That name already exists.");
      else {
        Session.set('playerID', Players.insert({name: $('#nameInput').val()}));
        console.log("Character created!");
      }
      $('#nameInput').val('');
    }
  };
}*/

if (Meteor.isServer) {
  Meteor.startup(function () {
    // code to run on server at startup
  });
}