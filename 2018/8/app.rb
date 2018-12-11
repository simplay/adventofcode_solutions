input = File.open('data.txt').readlines.map do |line|
  f = line.strip
  f.scan(/(\s*-?\d+,\s*-?\d+)/).map do |pair|
    pair.first.split(',').map &:to_i
  end
end

ps = input.map &:first
vs = input.map &:last

def print_stars(ps, xmin, xmax, ymin, ymax, iter=0)
  puts "seconds passed: #{iter}"
  puts

  psx = ps.map do |p|
    p.first - xmin
  end
  psy = ps.map do |p|
    p.last - ymin
  end

  pn = psx.zip(psy)
    (0..psy.max).each do |n|
      (0..psx.max).each do |m|
      if pn.any? { |p| p[0] == m && p[1] == n }
        print("o")
      else
        print(" ")
      end
    end
    puts
  end

  puts
end

min_area = 100_000_000_000
iter = 1
xmin = nil; xmax = nil
ymin = nil; ymax = nil

loop do
  ps_new = ps.each_with_index.map do |p, idx|
    [p[0] + vs[idx][0], p[1] + vs[idx][1]]
  end

  psx = ps_new.map(&:first)
  psy = ps_new.map(&:last)

  xmin, xmax = psx.minmax
  ymin, ymax = psy.minmax

  area = (xmax - xmin) * (ymax - ymin)
  if (area < min_area)
    min_area = area
  else
    psx = ps.map(&:first)
    psy = ps.map(&:last)

    xmin, xmax = psx.minmax
    ymin, ymax = psy.minmax
    print_stars(ps, xmin, xmax, ymin, ymax, iter)
    break
  end
  ps = ps_new
  iter += 1
end
