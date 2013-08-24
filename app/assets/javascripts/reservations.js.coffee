
app = angular.module("Nails", ["ngResource", "infinite-scroll"])

app.factory "Reservation", ["$resource", ($resource) ->
  $resource("/reservations/date/:date.json", {date: "@date"})
]

@ReservationCtrl = ["$scope", "Reservation", ($scope, Reservation) ->
  $scope.reservations = []
  $scope.days = []
  $scope.hours = [7..21]

  $scope.weekday_options = {weekday: "long"}
  $scope.date_options = {year: "numeric", month: "short", day: "numeric"}

  $scope.init = () ->
    $scope.days = $scope.initializeDates()

  $scope.loadMore = () ->
    last_day = $scope.days[$scope.days.length - 1]
    day = new Date(last_day.getTime() + (24*60*60*1000))
    $scope.days.push(day)
    $scope.updateReservations(day)

  $scope.initializeDates = () ->
    days = []
    day = new Date()
    for i in [0..4] by 1
      day = new Date(day.getTime() + (24*60*60*1000))
      days.push(day)
      $scope.updateReservations(day)
    return days

  $scope.updateReservations = (day) ->
    $scope.reservations[day] = Reservation.query({date: day.toLocaleDateString("en-US", {year: "numeric", month: "short", day: "numeric"})})

]