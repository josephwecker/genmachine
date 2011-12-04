class Object
  def pretty_inspect
    require 'pp'
    require 'stringio'
    old_out = $stdout
    begin
      s=StringIO.new
      $stdout=s
      pp(self)
    ensure
      $stdout=old_out
    end
    s.string
  end
end


def b(v)
  v = v[0].ord if v.is_a? String
  v.chr.pretty_inspect.strip + ' - ' +  (v & 0xff).to_s(2).rjust(8,'0').insert(4,'-')
end



=begin
def common_bits(nums)
  mask = 0xff
  mask_res = mask
  for n in nums
    #puts "| mask: #{b(mask)} | mask_res: #{b(mask_res)} | input: '#{n.chr}' - #{b(n)}"
    mask2 = 0xff & (~ (mask_res ^ (mask & n)))
    mask = mask & mask2
    mask_res = mask & n
  end
  common = b(mask).count('1')
  puts ''
  puts ''
  puts mask.to_s(16) + ' | ' + b(mask)
  puts mask_res.to_s(16) + ' | ' + b(mask_res)
  puts "common: #{common}"
  return [mask, mask_res, common]
end
=end

def common_bits(*nums)
  nums.map!{|n| (n.is_a?(String) ? n[0].ord : n)}
  mask = 0xff
  mask_res = nums.shift
  puts b(mask_res)
  for n in nums
    puts b(n)
    new_mask = 0xff & (~ (mask_res ^ (mask & n)))
    mask = mask & new_mask
    mask_res = n & mask
  end
  common = b(mask).count('1')
  return [b(mask), b(mask_res), common]
end
