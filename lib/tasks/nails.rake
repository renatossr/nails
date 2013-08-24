namespace :nails do

  desc "Populate Nails with sample reservation data"
  task :fake_reservations => :environment do
    require 'populator'
    Reservation.destroy_all
    (Date.today..Date.today+10.days).each do |day|
      start = ((day.beginning_of_day+8.hour)..(day.beginning_of_day+16.hour)).step(30*60)
      

      10.times do
        description = Populator.words(3..6)
        kind = Reservation.kinds_of_reservation.sample
        status = "Reserved"
        start_time = start.sample
        end_time = start_time+([*1..2].sample).hour
        r = Reservation.new(start_time: start_time, end_time: end_time, description: description, kind: kind, status: status)
        if !r.save
          puts r.errors.messages
        end
      end
    end
  end

end
