require 'aws-sdk-dynamodb'


def tomtest()
  dynamodb = Aws::DynamoDB::Client.new(region: 'us-east-2')
  result_item = nil
  begin
    params = {
      table_name: 'GoogleCalendarIDs',
      key: { google_id: "106468044083943513288" }
    }

    result_item = dynamodb.get_item(params)&.item || {}
  rescue Exception => e
    return
  end
  result_item.to_s << "finished"
end

RubyVM::InstructionSequence.compile_option = true
compiled_code = RubyVM::InstructionSequence.of(method(:tomtest))
binary_code = compiled_code.to_binary

binary_file = File.open('test.bin','w+')
binary_file.puts binary_code
binary_file.close
