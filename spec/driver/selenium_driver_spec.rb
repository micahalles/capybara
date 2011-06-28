require 'spec_helper'
require 'rbconfig'

describe Capybara::Selenium::Driver do
  before do
    @driver = TestSessions::Selenium.driver
  end

  describe "Node" do
    before do
      @driver = mock
      @native = mock
      @node = Capybara::Selenium::Node.new(@driver, @native)
    end

    describe "#text" do
      it "returns text from the native driver" do
        @native.should_receive(:text).and_return('happy capybara')
        @node.text.should == 'happy capybara'
      end

      it "returns '' if the the element has been removed from the dom" do
        @native.should_receive(:text).and_raise(Selenium::WebDriver::Error::ObsoleteElementError.new('angry capybara'))
        @node.text.should == ''
      end
    end

    describe "#visible?" do
      it "returns visibility based on the native driver" do
        @native.should_receive(:displayed?).and_return('true')
        @node.should be_visible
        @native.should_receive(:displayed?).and_return('false')
        @node.should_not be_visible
      end

      it "returns text from the native driver" do
        @native.should_receive(:displayed?).and_raise(Selenium::WebDriver::Error::ObsoleteElementError.new('angry capybara'))
        @node.should_not be_visible
      end
    end
  end

  it_should_behave_like "driver"
  it_should_behave_like "driver with javascript support"
  it_should_behave_like "driver with resynchronization support"
  it_should_behave_like "driver with frame support"
  it_should_behave_like "driver with support for window switching"
  it_should_behave_like "driver without status code support"
  it_should_behave_like "driver with cookies support"

  unless Config::CONFIG['host_os'] =~ /mswin|mingw/
    it "should not interfere with forking child processes" do
      # Launch a browser, which registers the at_exit hook
      browser = Capybara::Selenium::Driver.new(TestApp).browser

      # Fork an unrelated child process. This should not run the code in the at_exit hook.
      pid = fork { "child" }
      Process.wait2(pid)[1].exitstatus.should == 0

      browser.quit
    end
  end
end
