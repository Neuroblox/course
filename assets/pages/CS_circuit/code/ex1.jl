# This file was generated, do not modify it. # hide
macro OUTPUT()# hideall
    return isdefined(Main, :Franklin) ? Franklin.OUT_PATH[] : "/tmp/"
end;