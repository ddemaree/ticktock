#
#  THIS FILE IS NONSENSE. IT IS GENERATED BY RAGEL, AND IS NOT
#  MEANT TO BE HUMAN READABLE CODE. BEST TO JUST SHRUG YOUR
#  SHOULDERS AND MOVE ON. ALL THAT MATTERS IS THAT YOU CAN CALL
#
#		Ticktock::Parser._parse(string)
#
#	 TO TRANSLATE A STRING IN TICKTOCK MESSAGE FORMAT INTO
#  A PARAMS HASH.
#

class Ticktock::Parser

		class ParseError < ::SyntaxError; end

		class << self

%%{
	machine hello;

	action start {
		tokstart = p;
	}

	action word {
		word = data[tokstart..p-1]
	}
	
	action key {
    key = word
    results[key] ||= []
  }
  
  action default {
    key = nil
  }

	action body {
		body << (word + ' ')
	}
	
	action tag {
		(results['tags'] ||= []) << word
		body << ('#' + word + ' ')
	}
	
	action project {
		results['subject'] = word
	}
	
	action flag {
		results[word] = true
	}

	action value {
    (results[key || :default] ||= []) << word
  }

  action quote { quotes += 1 }
  action unquote { quotes -= 1 }

	# Alphanumeric/text matchers #
	bareword = ( [^ '"(:#@!] . [^ "):]* ) > start % word ; # allow apostrophes		
	dquoted  = '"' @ quote ( [^"]* > start % word ) :>> '"' @ unquote;
	squoted  = '\'' @ quote ( [^']* > start % word ) :>> '\'' @ unquote;
	anyword  = dquoted | squoted | bareword ;
	
	# Excludes nonalphanumeric chars
	keyword = (alpha [0-9a-zA-Z_\-]*) > start % word ;

	# Date/time matchers #
	
	action initdate { results["date"] ||= {} }
	action setyear  { results["date"]["year"]  = word; }
	action setmonth { results["date"]["month"] = word; }
	action setday   { results["date"]["day"]   = word; }

	action compiledate {
		date = results["date"]

		m, d, y = date["month"].to_i,
							date["day"].to_i,
							(date["year"] || Date.today.year).to_i

	  results["date"] = Date.civil(y,m,d)
		word = ""
	}
	
	datekw = 'd:' | 'date:' ;
	datestring_h = datekw* > initdate
												 ((('19'|'20') [0-9]{2}) > start % word % setyear '-'
												  ([0-9]{2}) > start % word % setmonth '-'
												  ([0-9]{2}) > start % word % setday )
												  % compiledate ;
													
	datestring_s = datekw*  > initdate
													([0-9]{1,2} > start % word % setmonth '/'
													 [0-9]{1,2} > start % word % setday '/'
													 (('19'|'20')[0-9]{2}) > start % word % setyear )
													% compiledate ;
													
	datestring = datestring_s | datestring_h ;

	action inittime   { dur = {} unless dur.is_a?(Hash) }
	action sethours   { dur["h"] = data[tokstart..p-1] }
	action setminutes { dur["m"] = data[tokstart..p-1] }
	action setseconds { dur["s"] = data[tokstart..p-1] }

	action compiletime {
		begin
			h, m, s = (dur["h"]||0).to_i, (dur["m"]||0).to_i, (dur["s"]||0).to_i

			ts = 0
			ts += h * 3600
			ts += m * 60
			ts += s

			results["duration"] = ts
		rescue => @e
			results["duration"] = dur.inspect
		end
	}

	duration_c = '' > inittime
							 [0-9]{1,2} > start % sethours ':'
							 [0-9]{2} > start % setminutes
							 (':' ([0-9]{2}) > start % setseconds)*
							 % compiletime ;
							
	duration_s = '' > inittime
							 (([0-9]+ > start % sethours) 'h')*
							 (([0-9]+ > start % setminutes) 'm')*
							 :>> '' % compiletime ;
							
	timestring = duration_c | duration_s;

	bodyword   = anyword % body ;
	pair       = keyword % key ':' anyword % value ;
	hashtag    = '#' (bareword) % tag ;
	atproject  = '@' (anyword) % project ;
	bang       = '!' (keyword) % flag ;
	
	param  = (datestring | timestring | hashtag | bang | atproject | pair | bodyword);
	params = param (' '+ param)*;
	
	main := ' '* params? ' '* 0
          @!{ raise ParseError, "At offset #{p}, near: '#{data[p,10]}'" };

}%%
    
			def _parse(input) #:nodoc:
				data = input + ' '
				%% write data;
				p = 0
				eof = nil
				word = nil
				pe = data.length
				key = nil
				tokstart = nil
				results = {}
				values = []
				quotes = 0
		
				date = {}
				dur = {}
				
				dt_comps = []
		
				body = ""
		
				%% write init;
				%% write exec;
				unless quotes.zero?
					raise ParseError, "Unclosed quotes"
				end
				
				results["body"] = body.gsub(/ +/," ").strip
				results
			end

		end
end