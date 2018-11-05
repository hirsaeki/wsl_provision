#!/usr/bin/ruby -Ke
# -*- coding: euc-jp -*-
# http://rubyist.g.hatena.ne.jp/znz/20060924/p1
#
# はてなダイアリーキーワードふりがなリストをSKKの辞書に変換
#
# 使い方:
#  wget http://d.hatena.ne.jp/images/keyword/keywordlist_furigana.csv
#  ruby keywordlist_furigana2skkdic.rb keywordlist_furigana.csv > tmp.skkdic
#  skkdic-expr2 -o keywordlist_furigana.skkdic tmp.skkdic
#
# 同一の読みをまとめたりはしていないので、一度skkdic-expr2を通してください。
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
    # []の処理をしないとskkdic-expr2がSEGVる。
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
    next # ふりがながないキーワードを無視
  end
  if furigana == keyword
    next # ひらがなだけのキーワードを無視
  end
  if furigana == NKF.nkf('-Ee -m0 --hiragana', keyword)
    next # カタカナ語は無視
  end
  puts "#{furigana} /#{keyword.gsub(/&amp;/, '&').concatify}/"
end
