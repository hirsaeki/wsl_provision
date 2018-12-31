#!/usr/bin/ruby -Ke
# -*- coding: euc-jp -*-
# http://rubyist.g.hatena.ne.jp/znz/20060924/p1
#
# �ϤƤʥ������꡼������ɤդ꤬�ʥꥹ�Ȥ�SKK�μ�����Ѵ�
#
# �Ȥ���:
#  wget http://d.hatena.ne.jp/images/keyword/keywordlist_furigana.csv
#  ruby keywordlist_furigana2skkdic.rb keywordlist_furigana.csv > tmp.skkdic
#  skkdic-expr2 -o keywordlist_furigana.skkdic tmp.skkdic
#
# Ʊ����ɤߤ�ޤȤ᤿��Ϥ��Ƥ��ʤ��Τǡ�����skkdic-expr2���̤��Ƥ���������
#
#
# License:
#
# Copyright (c) 2006-2009 Kazuhiro NISHIYAMA
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'nkf'

class String
  # borrowed from http://openlab.jp/skk/skk/tools/filters/skkdictools.rb
  def concatify
    #if !(/^([-\w]+.*)$/ =~ self) && (/[;\r\n\/\"]/ =~ self)
    # []�ν����򤷤ʤ���skkdic-expr2��SEGV�롣
    # see http://d.hatena.ne.jp/rubikitch/20091022/1256186001
    if /[\[\];\r\n\/\"]/ =~ self
      tmp = self.gsub(/;/, '\\\073').gsub(/\//, '\\\057').gsub(/\r/, '\\r').gsub(/\n/, '\\n').gsub(/"/, '\\"').gsub(/[\[\]]/, '')
      return '(concat "' + tmp + '")'
    else
      return self
    end
  end
end

# http://d.hatena.ne.jp/hatenadiary/20060922/1158908401
# http://d.hatena.ne.jp/images/keyword/keywordlist_furigana.csv
ARGF.each do |line|
  line.chomp!
  furigana, keyword = line.split(/\t/, 2)
  if furigana.empty?
    next # �դ꤬�ʤ��ʤ�������ɤ�̵��
  end
  if furigana == keyword
    next # �Ҥ餬�ʤ����Υ�����ɤ�̵��
  end
  if furigana == NKF.nkf('-Ee -m0 --hiragana', keyword)
    next # �������ʸ��̵��
  end
  puts "#{furigana} /#{keyword.gsub(/&amp;/, '&').concatify}/"
end
