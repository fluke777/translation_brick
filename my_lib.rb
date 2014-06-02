require 'bundler/setup'
require 'gooddata'

JAP_TEXT =" 䨺横ツォ 䨺横ツォく駺 びょ骤つびコ 椥䦤ひゅ綩勯 ぎゅみょ 䤎矤 驦こば し廨やリュ訧 すぜぎゅみょ祚, みゅ䨯誧 襊樊穃娩䏦 ぢゃ夯狦稧は 觧ヒャテをソ 榚黨, 襊樊穃娩䏦 黨じゅぶほじ 褩鰥 覌すぜ し廨やリュ訧 饣㠨で槎廩 儯馦ちょ 䤩詞 䧞椥䦤 鄯嫯頨秵諧 篞階詃楟䦨 穃娩, 饯ちゃりょご裃 に骣へ䛨ぼ ヂョ蟦の 饣㠨, 勯に 䩵橎ちゅ 䤥.れ穞姥 驚餥ぽキャ婩 襧䦌揨っヴョ 横ツォ さゆゞ 姨ちペ襃妣 氩ぱ禤ヴャ窯"

def connect
  GoodData.connect('', '')
end

def generate_jap_word(length)
	(1..length).map {|x| JAP_TEXT[rand(JAP_TEXT.length)]}.join('')
end

def generate_template()
  connect
	GoodData.with_project('tjamtzg8m4udx3h9yfuv95lrftmwdxn2') do |p|

		items = [
			GoodData::Attribute,
			GoodData::Metric,
			GoodData::Report,
			GoodData::Dashboard
		]

		exported = items.reduce([]) do |a, e|
			e.send(:all).each do |item|
				a << {
					:id => item['link'].split('/').last,
					:title => item['title'],
					:description => item['summary'],
					:type => item['category']
				}
			end
			a
		end

		File.open('eng_temaplate.json', 'w') do |f|
			f << JSON.pretty_generate(exported)
		end;
	end
end

def generate_translation
	File.open('jp_translation.json', 'w') do |f|
		template = JSON.parse(File.read('eng_temaplate.json'))
		translation = template.map do |template|
			{
				:id => template['id'],
				:title => generate_jap_word(3),
				:description => generate_jap_word(5)
			}
		end
		f << JSON.pretty_generate(translation)
	end
end

def translate_project
  connect
  count = 0
  GoodData.logging_on
	GoodData.with_project('tjamtzg8m4udx3h9yfuv95lrftmwdxn2') do |p|

		stuff = JSON.parse(File.read('jp_translation.json'))
		stuff.each do |item|
		  count += 1
		  puts "#### #{count} - #{Time.now}"
		  obj = GoodData::MdObject[item['id']]
		  obj.title = item['title']
		  obj.summary = item['description']
		  obj.save
	  end
	end
end