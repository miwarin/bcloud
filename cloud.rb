#!/usr/bin/ruby -Ku

def analysis(inputfile)
  mecab_cmd = ' /cygdrive/c/Program\ Files\ \(x86\)/MeCab/bin/mecab.exe'
  text = `#{mecab_cmd} -b 81920 #{inputfile}`
  words = []
  lines = text.split("\n")
  lines.grep(/固有名詞/) {|line|
    words << line.split("\t")[0]
  }

  return words

end

# 解析結果の単語の出現数を単語ごとに数える
def tag(text)
  word_count ||= {}
  word_count.default = 0
  text.each { |w|
    word_count[w] += 1
  }
  
  return word_count
  
end

def html(contents)
  out_html = ""
  out_html << make_header()
  out_html << make_css()
  out_html << contents
  out_html << make_footer()
  return out_html
end


def make_css()
  css = ""
  css << "\t<style type=\"text/css\">\n"
  0.upto(24) { |level|
    font = 12 + level
    css << "\tli.tagcloud#{level} {font-size: #{font}px;}\n"
  }

  css << "\t.tagcloud {line-height:1}\n"
  css << "\t.tagcloud ul {list-style-type:none;}\n"
  css << "\t.tagcloud li {display:inline;}\n"
  css << "\t.tagcloud li a {text-decoration:none;}\n"
  css << "\t</style>\n"
  return css
end

  
def make_header()
  out_html = <<EOS
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>タグクラウド</title>
</head>
<body>
EOS
  return out_html
end
  
def make_footer()
  out_html = <<EOS
</body>
</html>
EOS

  return out_html
end


# 解析結果からタグクラウド作成
def tagcloud(tags)
  max_level = Math.sqrt(tags.values.max)
  min_level = Math.sqrt(tags.values.min)
  
  factor = 1.0
  if ((max_level - min_level) == 0)
    min_level = min_level - 24
    factor = 1
  else
    factor = 24 / (max_level - min_level)
  end

  tagcloud_html = ""
  tagcloud_html << "<ul class=\"tagcloud\">"

  tags.each { |tag, count|
    level = ((Math.sqrt(count.to_i) - min_level) * factor).to_i
    tagcloud_html << "<li class=\"tagcloud#{level}\">#{tag}</li>\n"
  }

  tagcloud_html << "</ul>"

  return tagcloud_html

end


def output(filepath, contents)
  File.open(filepath, "w").write(contents)
end

def build(infile, outfile)
  analyzed_text = analysis(infile)
  tags = tag(analyzed_text)
  tagcloud_html = tagcloud(tags)
  out_html = html(tagcloud_html)
  output(outfile, out_html)
end


if __FILE__ == $0
  def main(argv)
    infile = argv[0]
    outfile = argv[1]
    build(infile, outfile)
  end

  main(ARGV)
