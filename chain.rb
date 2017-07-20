require 'rubygems'
require 'digest'
require 'pry'

class Block
  attr_accessor :index, :timestamp, :data, :previous_hash, :hash

  def initialize(index, timestamp, data, previous_hash)
    self.index = index
    self.timestamp = timestamp
    self.data = data
    self.previous_hash = previous_hash

    self.hash = self.hash_block
  end

  def hash_block
    sha = Digest::SHA256.new
    sha.update self.index.to_s + self.timestamp.to_s + self.data.to_s + previous_hash.to_s
    sha.hexdigest
  end

  def rehash!
    self.timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S.%6N")
    self.hash = hash_block
  end

  def self.genesis_block
    Block.new(0, Time.now.strftime("%Y-%m-%d %H:%M:%S.%6N"), "Genesis Block", 0)
  end

  def self.mine_next_block(last_block)
    this_index = last_block.index + 1
    this_timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S.%6N")
    this_data = "Block data for index " + this_index.to_s
    this_hash = last_block.hash

    Block.new(this_index, this_timestamp, this_data, this_hash)
  end
end

class Blockchain
  attr_accessor :blocks

  def initialize
    self.blocks = [Block.genesis_block]
  end

  # Simple string comparison between two hashes, e.g. 0a0 < 1b5 < 1c0 < 1c5 < 535 etc
  def self.better_hash? existing_hash, challenging_hash
    challenging_hash.to_s < existing_hash.to_s
  end

  def add(block)
    if Blockchain.better_hash?(self.blocks.last.hash, block.hash)
      self.blocks.push block
      true
    else
      false
    end
  end
end

blockchain = Blockchain.new
while true
  block_to_add = Block.mine_next_block(blockchain.blocks.last)

  until blockchain.add(block_to_add)
    block_to_add.rehash!
    #puts "Retrying with new hash: #{block_to_add.hash}"
  end

  puts "Block #{block_to_add.index} has been added to this blockchain!"
  puts "Hash: #{block_to_add.hash}\n"
end
