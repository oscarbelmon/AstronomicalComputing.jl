export JulianDay
export isinvalid

struct JulianDay
    year::Int64
    month::Int64
    day::Int64
    hour::Int64
    minute::Int64
    second::Float64
    JulianDay(year::Int64, moth::Int64, day::Int64) = isinvalid(year, moth, day) ? error("Invalid date") : new(year, moth, day, 0, 0, 0)
    JulianDay(t::Int64) = new(set_from_jd(date_to_julian_day(1970, 1, 1, false) + t / 86400000)...)
    JulianDay(julianday::Float64) = new(set_from_jd(julianday)...)
end

const START_INVALID::JulianDay = JulianDay(1582, 10, 4)
const END_INVALID::JulianDay = JulianDay(1582, 10, 15)

function set_from_jd(julianday::Float64)
    z = trunc(Int, abs(julianday) )
    if julianday < 0
        z = -z
    end
    a = z
    if z >= 2299161.0
        a2 = trunc(Int, (z - 1867216.25) / 36524.25)
        a = a + 1 + a2 - trunc(Int, a2 / 4)
    end
    b = a + 1524
    c = trunc(Int, (b - 122.1) / 365.25)
    d = trunc(Int, (c * 365.25))
    e = trunc(Int, (b - d) / 30.6001)
    f = julianday + 0.5 - z
    exactday = f + b - d - trunc(30.6001 * e)
    day = trunc(Int, exactday)
    month = e - 1
    if month > 12
        month = month - 12
    end
    year = c - 4715
    if month > 2
        year = year - 1
    end
    hour, minutes, second = set_day_fraction(exactday - day)
    return year, month, day, hour, minutes, second
end

function get_day_fraction(julianday::JulianDay)
    return (julianday.hour + julianday.minute / 60 + julianday.second / 3600) / 24
end

function set_day_fraction(fraction::Float64)
    frac = fraction * 24
    hour = trunc(Int, frac)
    frac = (frac - hour) * 60
    minute = trunc(Int, frac)
    second = (frac - minute) * 60
    return hour, minute, second
end

function get_julian_day(julianday::JulianDay)
    return date_to_julian_day(julianday.year, julianday.month, julianday.day, isjulian(julianday)) + get_day_fraction(julianday)
end

function isinvalid(julianday::JulianDay)
    return julianday.year == 1582 && julianday.month == 10 && (julianday.day >= 5 && julianday.day < 15)
end

function isinvalid(year::Int64, month::Int64, day::Int64)
    return year == 1582 && month == 10 && (day >= 5 && day < 15)
end

function isjulian(julianday::JulianDay)
    # if julianday.year < 1582
    #     return true
    # elseif julianday.year == 1582 && julianday.month < 10
    #     return true
    # elseif julianday.year == 1582 && julianday.month == 10 && julianday.day < 15
    #     return true
    # else
    #     return false
    # end
    return julianday < START_INVALID
end

function date_to_julian_day(year::Int64, month::Int64, day::Int64, julian::Bool)::Float64
    if month < 3
        year = year - 1
        month = month + 12
    end
    a::Int64 = year ÷ 100
    b::Int64 = 0
    if !julian
        b = 2 - a + a ÷ 4
    end
    return trunc(Int, 365.25 * (year + 4716)) + trunc(Int, 30.6001 * (month + 1)) + day + b - 1524.5
end

Base.:(==)(d1::JulianDay, d2::JulianDay) = d1.year == d2.year && d1.month == d2.month && d1.day == d2.day

Base.:(>)(d1::JulianDay, d2::JulianDay) = d1.year > d2.year || d1.month > d2.month || d1.day > d2.day

Base.:(<)(d1::JulianDay, d2::JulianDay) = d1.year < d2.year || d1.month < d2.month || d1.day < d2.day


Base.show(io::IO, julianday::JulianDay) = print(io, string(julianday.year) * "-" * 
                                                string(julianday.month) * "-" * 
                                                string(julianday.day) * " " *
                                                string(julianday.hour) * ":" *
                                                string(julianday.minute) * ":" *
                                                string(julianday.second))
