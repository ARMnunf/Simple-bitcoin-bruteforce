require 'digest'
require 'uri'
require 'base58'
require 'net/http'
require 'json'
require 'ecdsa'
require 'securerandom'

def hexlify(msg)
	msg.split("").collect { |c| c[0].to_s(16) }.join
end

def unhexlify(msg)
	msg.scan(/../).collect { |c| c.to_i(16).chr }.join
end

def SHA256(msg)
	Digest::SHA256.hexdigest unhexlify(msg)
end

def RIP160(msg)
	Digest::RMD160.hexdigest unhexlify(msg)
end

def ecdsa_encypt(msg)
	b=0
	group = ECDSA::Group::Secp256k1
	pub_key = group.generator.multiply_by_scalar(msg.to_i(16))
	if pub_key.y%2==0
		b="02"
	else
		b="03"
	end
	msg = b+pub_key.x.to_s(16)
end

def make_wallet msg
	msg=RIP160(SHA256(ecdsa_encypt(msg)))
	msg="00"+msg
	msg_b=SHA256((SHA256(msg)))
	msg_b= msg+msg_b[0,8]
	msg = "1"+Base58.int_to_base58(msg_b.to_i(16), :bitcoin)
end
#count=0
simu = 0
seed ='000000000000000000000000000000000000000000000000000000000000000e'  						#put something in the quote like 'Hi'
a= seed
while(simu!="exit")do

b = make_wallet(a)

url = 'https://blockchain.info/rawaddr/'+b.to_s
uri = URI(url)
response = Net::HTTP.get(uri)
begin
  js= JSON.parse(response)
rescue JSON::ParserError
  # Handle error
end
current = js["final_balance"]
puts a.to_s+"\n"+b.to_s+" : "+current.to_s

if js["final_balance"].to_i!=0
	simu=gets
end
#str!=start_text
a = SHA256(b)
end




 
 