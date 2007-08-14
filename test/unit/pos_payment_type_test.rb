require File.dirname(__FILE__) + '/../test_helper'

class PosPaymentTypeTest < Test::Unit::TestCase
  fixtures :pos_payment_types, :customers



  def test_needs
      PosPaymentType.find_all.each do | pt |
          assert_kind_of(  Array, pt.needs )
      end
      assert_equal( PosPaymentType::CREDIT_CARD.needs.size, 3 )
  end

   def test_data
       cust=Customer.find_by_code( DEF::ACCOUNTS['POS_CASH'] )
       PosPaymentType.all do | pt |
           pt.data=Array[ cust.code ]
           assert( pt.ok? )
       end
  end

   def test_types
       assert_kind_of( PosPaymentType::CreditCardTerminal, PosPaymentType::CC_TERMINAL )
       assert_kind_of( PosPaymentType::Cash, PosPaymentType::CASH )
       assert_kind_of( PosPaymentType::Check, PosPaymentType::CHECK )
       assert_kind_of( PosPaymentType::BillingAccount, PosPaymentType::BILLING )
       assert_kind_of( PosPaymentType::GiftCertificate, PosPaymentType::GIFT_CERT )
       assert_kind_of( PosPaymentType::YourPayCreditCard, PosPaymentType::CREDIT_CARD )
   end


   def test_validations
       %w(  POS_CASH POS_CHECK POS_GIFT_CERT POS_CREDIT_CARD ).each do | acct |
           DEF::ACCOUNTS[ acct ]='NORM'
       end

       pt=PosPaymentType::CC_TERMINAL
       pt.data=Array['']
       assert( ! pt.ok? )
       assert( pt.error_msg =~ /not entered/ )
       pt.data=Array[ '244363485093480' ]
       assert( pt.ok? )
       assert( pt.customer )
       assert_equal( '244363485093480',pt.transaction )


       pt=PosPaymentType::CHECK
       pt.data=Array['']
       assert( ! pt.ok? )
       assert( pt.error_msg =~ /not entered/ )
       pt.data=Array['blub']
       assert( pt.ok? )
       assert( pt.customer )
       assert_equal( 'blub',pt.transaction )

       pt=PosPaymentType::BILLING
       pt.data=Array['']
       assert( ! pt.ok? )
       assert( pt.error_msg =~ /not found/ )
       pt.data=Array['SPEC']
       assert_raise( NameError ) do
           assert( pt.ok? )
       end
       assert( pt.customer )
       assert_equal( 'SPEC',pt.transaction )

       pt=PosPaymentType::GIFT_CERT
       pt.data=Array['']
       assert( ! pt.ok? )
       assert( pt.error_msg =~ /not entered/ )
       pt.data=Array['nothing']
       assert( pt.customer )
       assert_equal( 'nothing',pt.transaction )

       pt=PosPaymentType::CREDIT_CARD
       pt.data=Array['']
       assert( ! pt.ok? )
       assert( pt.error_msg =~ /not entered/ )
       pt.data=Array['nothing']
       assert( pt.customer )
       assert_equal( '',pt.transaction )

   end

end
