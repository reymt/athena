angular.module('arachne')
.factory('LastTab', function() {
    var tab = new Array();

    return {
        get: function(name) {
            for (var i=0; i<tab.length; i++) {
                if (tab[i].name === name) {
                    return tab[i].last;
                }
            }
            return '';
        },

        set: function(name, currtab) {
            for (var i=0; i<tab.length; i++) {
                if (tab[i].name === name) {
                    tab[i].last = currtab;
                    return;
                }
            }

            var obj = {'name' : name, 'last' : currtab};
            tab.push(obj);
        }
    };
});