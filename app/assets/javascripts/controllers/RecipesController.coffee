controllers = angular.module('controllers')

controllers.controller("RecipesController", [ '$scope', '$routeParams', '$location', '$resource',
  ($scope,$routeParams,$location,$resource)->
    $scope.search = (keywords)->  $location.path("/").search('keywords',keywords)

    if $routeParams.keywords
      keywords = $routeParams.keywords.toLowerCase()
      $scope.recipes = recipes.filter (recipe)-> recipe.name.toLowerCase().indexOf(keywords) != -1
    else
      $scope.recipes = []

    $scope.view = (recipeId)-> $location.path("/recipes/#{recipeId}")
    $scope.newRecipe = -> $location.path("/recipes/new")
    $scope.edit = (recipeId)-> $location.path("/recipes/#{recipeId}/edit")
])

controllers.controller("RecipeController", [ '$scope', '$routeParams', '$resource', '$location', 'flash',
  ($scope,$routeParams,$resource,$location, flash)->

    Recipe = $resource('/recipes/:recipeId', { recipeId: "@id", format: 'json' },
      {
        'save':   {method:'PUT'},
        'create': {method:'POST'}
      }
    )

    if $routeParams.recipeId
      Recipe.get({recipeId: $routeParams.recipeId},
        ( (recipe)-> $scope.recipe = recipe ),
        ( (httpResponse)->
          $scope.recipe = null
          flash.error   = "There is no recipe with ID #{$routeParams.recipeId}"
        )
      )
    else
      $scope.recipe = {}

    $scope.back   = -> $location.path("/")
    $scope.edit   = -> $location.path("/recipes/#{$scope.recipe.id}/edit")
    $scope.cancel = ->
      if $scope.recipe.id
        $location.path("/recipes/#{$scope.recipe.id}")
      else
        $location.path("/")

    $scope.save = ->
      onError = (_httpResponse)-> flash.error = "Something went wrong"
      if $scope.recipe.id
        $scope.recipe.$save(
          ( ()-> $location.path("/recipes/#{$scope.recipe.id}") ),
          onError)
      else
        Recipe.create($scope.recipe,
          ( (newRecipe)-> $location.path("/recipes/#{newRecipe.id}/show") ),
          onError
        )

    $scope.delete = ->
      $scope.recipe.$delete()
      $scope.back()


])