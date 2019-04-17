require 'rails_helper'

describe BitcoinClient do
  describe "instance" do
    before do
      @client = described_class.new("127.0.0.1", "user", "password")
    end

    describe "help" do
      it "should call help rpc method" do
        expect(@client).to receive(:request).with("help")
        @client.help
      end
    end

    describe "getnetworkinfo" do
      it "should try getnetworkinfo rpc first" do
        expect(@client).to receive(:request).with("getnetworkinfo")
        @client.getnetworkinfo
      end
    end

    describe "getblockchaininfo" do
      it "should getblockchaininfo rpc method" do
        expect(@client).to receive(:request).with("getblockchaininfo")
        @client.getblockchaininfo
      end
    end

    describe "getbestblockhash" do
      it "should getbestblockhash rpc method" do
        expect(@client).to receive(:request).with("getbestblockhash")
        @client.getbestblockhash
      end
    end

    describe "getblock" do
      it "should getblock rpc method with hash" do
        expect(@client).to receive(:request).with("getblock", "hash")
        @client.getblock("hash")
      end
    end

    describe "getblockheader" do
      it "should getblockheader rpc method with hash" do
        expect(@client).to receive(:request).with("getblockheader", "hash")
        @client.getblockheader("hash")
      end
    end

    describe "gettxoutsetinfo" do
      it "should call gettxoutsetinfo rpc method" do
        expect(@client).to receive(:request).with("gettxoutsetinfo")
        @client.gettxoutsetinfo
      end
    end
  end
end
