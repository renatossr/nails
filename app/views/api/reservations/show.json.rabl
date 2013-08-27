object @reservation
attributes :id, :start_time, :end_time, :kind

node(:class)          { |reservation| reservation.kind.underscore.dasherize }
node(:left_position)  { |reservation| Reservation.web_horizontal_position(reservation) }
node(:width)          { |reservation| Reservation.web_size(reservation) }