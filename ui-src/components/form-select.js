module.exports = {
    inserted : function(select, binding) {

        // Create a div
        var div = document.createElement('div');
        div.classList.add('md-select');

        select.parentNode.insertBefore(div,select.nextSibling);
        
        // Hide this
        //select.style.display="none";

        // Add the input to such div
        div.appendChild(select);

        // Create a div that will act as the selected item
        var mainSelected = document.createElement('div');
        var selected = document.createElement('span');
        div.appendChild(mainSelected);
        mainSelected.classList.add("selected");
        selected.innerHTML = select.options[0].innerHTML;
        // Add edit icon
        var icon = document.createElement("i");        
        icon.classList.add("material-icons");        
        var activeT = document.createTextNode("arrow_drop_down");
        icon.appendChild(activeT);        
        icon.classList.add("active");        
        icon.style.fontSize="150%";
        icon.style.cssFloat = "right";        
        mainSelected.appendChild(selected);
        mainSelected.appendChild(icon);

        
        /*for each element, create a new DIV that will contain the option list:*/
        var items = document.createElement('div');
        items.classList.add('items');
        items.classList.add('hidden');

        // Add options to items
        var aux;
        for(var i=0; i < select.length; i++){
            aux = document.createElement('div');            
            aux.innerHTML = select.options[i].innerHTML;
            select.options[i].setAttribute('value',select.options[i].innerHTML.toLowerCase());
            items.appendChild(aux);
            aux.onclick = function(){
                selected.innerHTML = this.innerHTML;
                items.classList.toggle('hidden');   
                select.value = this.innerHTML.toLowerCase();
                mainSelected.classList.toggle("selected-arrow-active");
            }
        }
        div.appendChild(items);

        mainSelected.onclick = function(){
            items.classList.toggle('hidden');
            this.classList.toggle("selected-arrow-active");
        }

        
    }
}