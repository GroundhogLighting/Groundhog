(function() {
        var app = angular.module('archive', []);

        app.filter('markdown', function() {
            return function(text) {
                if (typeof text == "undefined") {
                    return "";
                }
                return markdown.toHTML(String(text));
            }
        });

        app.service('globalVariables',function(){
            this.products={};
            //this.categories={};
            this.active_product={};

            this.setProducts = function(newProducts){
                this.products = newProducts;
            };

//            this.setCategories = function(newCategories){
//                this.categories = newCategories;
//            };

            this.clear = function(){
                this.products={};
                this.active_product={};
            };

            this.activateProduct = function(product){
                this.active_product = product;
            };
        });

        app.factory('restService', ['$http','globalVariables', function($http,globalVariables){
            return {
                getProducts : function(url){
                    $http.get(url).success(function(data){
                        globalVariables.setProducts(data);
                    });
                },

            //    getCategories : function(){
            //        $http.get('/api/categories').success(function(data){
            //            globalVariables.setCategories(data);
            //        });
            //    }
            };
        }]);

        app.controller('AppController',['globalVariables','restService',function(globalVariables,restService){
            this.globalVariables=globalVariables;

            this.init = function(){
                restService.getProducts('http://localhost:8080/api/products');
                //restService.getCategories();
            };

            this.logOut = function(){
                this.globalVariables.clear();
                restService.getProducts('http://localhost:8080/api/products');
            };

            this.search = function(){
                var query = document.getElementById('omnibar').value;
                restService.getProducts('http://localhost:8080/api/products/_search/'+query);
            };

            this.showDatasheet = function(product){
                //this.globalVariables.activateProduct(product);
                //this.showWindow('datasheet');

                window.location.href = 'skp:get_model@'+JSON.stringify(product);
            };

            //this.showWindow = windowBehavior.showWindow;
            //this.hideWindow = windowBehavior.hideWindow;


        }]);
})();
