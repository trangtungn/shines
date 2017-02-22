var app = angular.module('creators', [
    'ngRoute',
    'templates'
]);

app.config([
    "$routeProvider",
    function ($routeProvider) {

        // configure our routes here...

        $routeProvider.when("/", {
            controller: "CreatorSearchController",
            templateUrl: 'creator_search.html'
        }).when('/:id', {
            controller: 'CreatorDetailController',
            templateUrl: 'creator_detail.html'
        });
    }
]);

var CreatorSearchCtlr = function ($scope, $http, $location) {

    var page = 0;
    $scope.creators = [];

    $scope.search = function (searchTerm) {
        if (searchTerm.length < 3) {
            return;
        }

        $scope.searchedFor = searchTerm;

        $http.get('/creators.json', {
            params: {
                keywords: searchTerm,
                page: page
            }
        }).success(function (data, status, headers, config) {
            $scope.creators = data;
        }).error(function (data, status, headers, config) {
              alert('There was a problem: ' + status);
          }
        );
    };

    $scope.previousPage = function () {
        if (page > 0) {
            page = page - 1;
            $scope.search($scope.keywords);
        }
    };

    $scope.nextPage = function () {
        page = page + 1;
        $scope.search($scope.keywords);
    };

    $scope.viewDetails = function (creator) {
        $location.path("/" + creator.id);
    }

};

app.controller('CreatorSearchController', ['$scope', '$http', '$location', CreatorSearchCtlr]);


app.controller("CreatorDetailController", [
    "$scope","$http","$routeParams",
    function($scope , $http , $routeParams) {

        // Make the Ajax call and set $scope.customer...

        var creatorId = $routeParams.id;
        $scope.creator = {};

        $http.get("/creators/" + creatorId + ".json").then(function(response) {
              $scope.creator = response.data;
          },function(response) {
              alert("There was a problem: " + response.status);
          }
        );
    }
]);