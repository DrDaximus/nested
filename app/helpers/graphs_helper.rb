module GraphsHelper


  def area_graph(data, height, width)

    case data
    when "hour"
      @data = @clicks.group_by_hour(:time, format: '%H:%M').count
      @title = "between #{@link.created_at.strftime('%H:%M on %d %b %y')} and #{@link.expires.strftime('%H:%M on %d %b %y')}"
    when "hour_of_day"
      @data = @clicks.group_by_hour_of_day(:time, day_start: @link.created_at.hour, format: "%H:%M").count
      @title = "over lifetime (#{link_life(@link)})"
    when "minutes"
      @data = @clicks.group_by_minute(:time, last: 60, format: "%H:%M").count
      @title = "in the past hour (#{(Time.now - 60.minutes).strftime('%H:%M')} - #{Time.now.strftime('%H:%M')})"
    end

    @count = @data.values.sum

    area_chart @data,
      colors: ["#9ED561"],
      width: width,
      height: height, 
      label: "Visits",
      library: {
      title: {text: pluralize(@count.to_s, "visit") + " " + @title},
      yAxis: {
        crosshair: true,
        allowDecimals: false,
        title: {
            text: "Visits"
        }
      },
      xAxis: {
        crosshair: true,
        title: {
            text: "Date/Time"
         }
      }
    }
  end
  
end