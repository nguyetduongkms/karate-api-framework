({
  timestamp: function() { return new Date().getTime(); },
  generateDate: function() { return new Date().toLocaleDateString(); },
  generateUsername: function() { return 'user_' + Math.floor(Math.random() * 100000); },
  generateEmail: function(username) { return username + '@anhtester.com'; },
  generateBookName: function() { return 'book_' + Math.floor(Math.random() * 100000); },
  generateBookPrice: function() { return Math.floor(Math.random() * 100) + 1; }
})