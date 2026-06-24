(function() {
  function timestamp() { return new Date().getTime(); }
  function generateDate() { return new Date().toLocaleDateString(); }
  function generateUsername() { return 'user_' + Math.floor(Math.random() * 100000); }
  function generateEmail(username) { return username + '@anhtester.com'; }
  function generateBookName() { return 'book_' + Math.floor(Math.random() * 100000); }
  function generateBookPrice() { return Math.floor(Math.random() * 100) + 1; }

  return {
    timestamp,
    generateDate,
    generateUsername,
    generateEmail,
    generateBookName,
    generateBookPrice
  };
})()