
app = angular.module("Nails", ["ngResource", "infinite-scroll"])

app.factory "Reservations", ["$resource", ($resource) ->
  $resource("/reservations/date/:date:format", {date: "@date"})
]

app.factory "Reservation", ["$resource", ($resource) ->
  $resource("/reservations/:id", {id: "@id"})
]

@ReservationCtrl = ["$scope", "Reservations", "Reservation", ($scope, Reservations, Reservation) ->
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
    $scope.reservations[day] = Reservations.query({date: day.toLocaleDateString("en-US", {year: "numeric", month: "short", day: "numeric"}), format: ".json"})

  $scope.addReservation = (day, reservation) ->
    if reservation
      reservation.status = "Reserved"
      r = Reservation.save(reservation
        (r) ->
          $scope.updateReservations(day)
        (response) ->
          console.log(response.data.errors)
      )

  $scope.addReservationByClick = (day, hour, minute) ->
    reservation = {}
    d = day.toLocaleDateString("en-US", {year: "numeric", month: "short", day: "numeric"})
    start_time = new Date(Date.parse(d + " " + hour + ":" + minute + ":00"))
    end_time = new Date(start_time.getTime() + (30*60*1000))
    reservation.start_time = start_time
    reservation.end_time = end_time
    reservation.status = "Reserved"
    $scope.addReservation(day, reservation)
    

  $scope.test = (day, hour, minute) ->
    day = day.toLocaleDateString("en-US", {year: "numeric", month: "short", day: "numeric"})
    console.log(day + '|' + hour + ':' + minute)

]