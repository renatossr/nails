
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
  DAY_LABEL_PIXEL_SIZE = 110
  RESERVATION_PIXEL_SIZE = 25
  ONE_HOUR = 60*60*1000 # One hour in miliseconds

  $scope.init = () ->
    $scope.initializeDates()


  $scope.initializeDates = () ->
    day = new Date
    day = new Date(day.getFullYear(), day.getMonth(), day.getDate(), 0, 0, 0, 0)
    for i in [0..9]
      day = new Date(day.getTime() + (24*ONE_HOUR))
      $scope.updateDay(day)


  $scope.updateDay = (day) ->
    $scope.days.push(day)
    $scope.updateReservations(day)


  $scope.updateReservations = (day) ->
    arr = Reservations.query({date: $scope.formatDate(day)}, () ->
      $scope.reservations[day] = $scope.treatEvents(arr)
    )


  $scope.loadMore = () ->
    last_day = $scope.days[$scope.days.length - 1]
    day = new Date(last_day.getTime() + (24*ONE_HOUR))
    $scope.updateDay(day)


  $scope.addReservation = (day, reservation) ->
    arr = []
    r = Reservation.save(reservation
      (resource) ->
        arr[0] = resource
        arr = $scope.renderPrepare(arr)
        $scope.reservations[day].push(arr[0])
      (response) ->
        console.log(response.status)
        console.log(response.data.errors)
    )


  $scope.addReservationByClick = (day, hour, minute) ->
    reservation = {}
    start_time = new Date(day.getFullYear(), day.getMonth(), day.getDate(), hour, minute, 0, 0)
    end_time = new Date(start_time.getTime() + (0.5*ONE_HOUR))
    reservation.start_time = start_time
    reservation.end_time = end_time
    reservation.kind = "Reservation"
    reservation.status = "Reserved"
    $scope.addReservation(day, reservation)


  $scope.formatDate = (day) ->
    return day = Math.round(day.getTime()/1000)


  $scope.formatWeekday = (str) ->
    console.log(str)
    return str.substr(0,1)


  $scope.mergeEvents = (arr) ->
    merged = []
    for r in arr
      mergedLast = merged[merged.length - 1]
      # Push reservation into array every time that the start_time of record is larger than reservation's start_time
      if merged.length == 0 || (Date.parse(r.start_time) > Date.parse(mergedLast.end_time))
        reservation = {}
        reservation.end_time = 0
        merged.push(reservation)
        # Reservation start_time only set at the beginning of each group
        merged[merged.length - 1].start_time = r.start_time
        merged[merged.length - 1].kind = r.kind
      # Reservation end_time set at the beginning of each group or if end_time of record is larger than reservation's end_time
      if Date.parse(r.end_time) > Date.parse(merged[merged.length - 1].end_time)
        merged[merged.length - 1].end_time = r.end_time
    return merged


  $scope.renderPrepare = (arr) ->
    for r in arr
      r.class = S(r.kind).dasherize().chompLeft('-').s
      r.left_position = $scope.eventLeftPosition(r)
      r.width = $scope.eventWidth(r)
    return arr


  $scope.eventLeftPosition = (r) ->
    startTime = new Date(r.start_time).getTime()
    beginningOfDay = new Date(r.start_time).setHours(0,0,0,0)
    return DAY_LABEL_PIXEL_SIZE + ( (startTime - (beginningOfDay + 7*ONE_HOUR) ) / (0.5*ONE_HOUR) ) * RESERVATION_PIXEL_SIZE


  $scope.eventWidth = (r) ->
    duration = Date.parse(r.end_time) - Date.parse(r.start_time)
    return RESERVATION_PIXEL_SIZE * duration / (0.5*ONE_HOUR)


  $scope.treatEvents = (arr) ->
    eventArray = []
    eventArray = $scope.mergeEvents(arr)
    eventArray = $scope.renderPrepare(eventArray)
    return eventArray

]