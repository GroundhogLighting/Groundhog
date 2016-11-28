var utilities = {};

utilities.fixName = function(name){
  return name.toLowerCase().replace(/\s/g, "_")
}

String.prototype.replaceAll = function(search, replacement) {
    var target = this;
    return target.replace(new RegExp(search, 'g'), replacement);
};
