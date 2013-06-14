(function() {
  $(function() {
    var getFullTree, parseTree;

    parseTree = function(data, $el) {
      return $.each(data, function(key, value) {
        var $new_node;

        $new_node = $("<ul/>").append($("<li/>").text(key));
        $el.append($new_node);
        if (typeof value === "object") {
          return $.each(value, function(i, value) {
            return parseTree(value, $new_node);
          });
        }
      });
    };
    getFullTree = function() {
      return $.ajax({
        url: "/tree.json",
        type: 'GET',
        dataType: 'json',
        beforeSend: function() {
          return console.log('Getting erlang tree...');
        },
        success: function(data) {
          return parseTree(data, $('#content'));
        },
        error: function(jqXHR, textStatus, errorThrown) {
          return console.log("Unable to get erlang tree from server! Error: " + errorThrown + " - " + textStatus);
        },
        complete: function() {
          return console.log('Request completed.');
        }
      });
    };
    return getFullTree();
  });

}).call(this);
