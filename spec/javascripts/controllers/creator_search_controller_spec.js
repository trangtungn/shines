describe("CreatorSearchController", function () {

  describe("Initialization", function () {

    var scope = null, controller = null;

    beforeEach(module("creators"));

    beforeEach(inject(function ($controller, $rootScope) {
      scope = $rootScope.$new();
      controller = $controller("CreatorSearchController", {
        $scope: scope
      });
    }));
    // tests go here...

    it("defaults to an empty customer list", function () {
      expect(scope.creators).toEqualData([]);
    });
  });
});

describe("Fetching Search Results", function () {

  var scope = null,
    controller = null,
    httpBackend = null,
    serverResults = [
      {
        id: 123,
        first_name: "Bob",
        last_name: "Jones",
        email: "bjones@foo.net",
        username: "jonesy"
      },
      {
        id: 456,
        first_name: "Bob",
        last_name: "Johnsons",
        email: "johnboy@bar.info",
        username: "bobbyj"
      }
    ];

  beforeEach(module("creators"));

  beforeEach(inject(function ($controller, $rootScope, $httpBackend) {
    scope = $rootScope.$new();
    httpBackend = $httpBackend;
    controller = $controller("CreatorSearchController", {
      $scope: scope
    });
  }));

  beforeEach(function () {
    httpBackend.when('GET', '/creators.json?keywords=bob&page=0').
      respond(serverResults);
  });

  // previous setup code

  it("populates the customer list with the results", function () {
    scope.search("bob");
    httpBackend.flush();
    expect(scope.creators).toEqualData(serverResults);
  });
});

describe("Error Handling", function () {

  // same setup as previous test...

  var scope = null,
    controller = null,
    httpBackend = null;

  beforeEach(module("creators"));

  beforeEach(inject(function ($controller, $rootScope, $httpBackend) {
      scope = $rootScope.$new();
      httpBackend = $httpBackend;
      controller = $controller("CreatorSearchController", {
        $scope: scope
      });
    }
  ));

  beforeEach(function () {
    httpBackend.when('GET', '/creators.json?keywords=bob&page=0').
      respond(500, 'Internal Server Error');
    spyOn(window, "alert");
  });

  it("alerts the user on an error", function () {
    scope.search("bob");
    httpBackend.flush();
    expect(scope.creators).toEqualData([]);
    expect(window.alert).toHaveBeenCalledWith(
      "There was a problem: 500");
  });
});