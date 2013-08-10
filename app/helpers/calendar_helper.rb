module CalendarHelper
  def calendar(date = Date.today, &block)
    Calendar.new(self, date, block).table
  end

  class Calendar < Struct.new(:view, :date, :callback)
    HEADER = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
    START_DAY = :sunday

    delegate :content_tag, to: :view

    def table
      content_tag :table, class: "calendar" do
        header + week_row + time_rows
      end
    end

    def header
      content = []
      content_tag :tr do
        content << content_tag(:td)
        content << HEADER.map { |day| content_tag :th, day }.join.html_safe
        content.join.html_safe
      end
    end

    def week_row
      content = []
      content_tag :tr do
        content << content_tag(:td)
        content << week.map { |day| day_cell(day) }.join.html_safe
        content.join.html_safe
      end
    end

    def time_rows
      hours.map do |hour|
        hour = DateTime.parse("#{hour}:00:00")
        content = []
        content << content_tag(:td, hour.strftime('%H:%M'))
        content_tag :tr do
          content << week.map { |week| time_cell(hour) }.join.html_safe
          content.join.html_safe
        end
      end.join.html_safe
    end

    def day_cell(day)
      content_tag :td, day.day, class: week_day_classes(day)
    end

    def time_cell(time)
      content_tag :td, view.capture(time, &callback)
    end

    def week_day_classes(day)
      classes = []
      classes << "day_header"
      classes << "today" if day == Date.today
      classes.empty? ? nil : classes.join(" ")
    end

    def time_classes(time)
      classes = []
      # classes << "now" if time == Time.now
      classes.empty? ? nil : classes.join(" ")
    end

    def week
      first = date.beginning_of_week(START_DAY)
      last = date.end_of_week(START_DAY)
      (first..last).to_a
    end

    def hours
      first = 7
      last = 21
      (first..last).to_a
    end
  end
end