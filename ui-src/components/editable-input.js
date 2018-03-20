module.exports = {
    inserted: function(input,binding){
                
        // Edit input
        input.placeholder="Not Set...";
        
        // Add edit icon
        var editIcon = document.createElement("i");
        editIcon.classList.add("material-icons");
        var t = document.createTextNode("mode_edit");
        editIcon.appendChild(t);
        editIcon.style.fontSize="inherit";
        input.parentNode.insertBefore(editIcon,input.nextSibling);

        
    }
}