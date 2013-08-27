
app = angular.module("Nails", ["ngResource", "infinite-scroll"])

app.factory "Reservations", ["$resource", ($resource) ->
  $resource("api/reservations/date/:date", {date: "@date"})
]

app.factory "Reservation", ["$resource", ($resource) ->
  $resource("api/reservations")
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
    $scope.reservations[day] = Reservations.query({date: $scope.formatDate(day)})

  $scope.addReservation = (day, reservation) ->
    r = Reservation.save(reservation
      (resource) ->
        $scope.reservations[day].push(resource)
      (response) ->
        console.log(response.status)
        console.log(response.data)
    )

  $scope.addReservationByClick = (day, hour, minute) ->
    reservation = {}
    d = $scope.formatDate(day)
    start_time = new Date(Date.parse(d + " " + hour + ":" + minute + ":00"))
    end_time = new Date(start_time.getTime() + (30*60*1000))
    reservation.start_time = start_time
    reservation.end_time = end_time
    reservation.kind = "Reservation"
    reservation.status = "Reserved"
    $scope.addReservation(day, reservation)
    

  $scope.formatDate = (day) ->
    return day = day.toLocaleDateString("en-US", {year: "numeric", month: "short", day: "numeric"})

]