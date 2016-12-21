global with sharing class ChargeStripeCustomer  {

    @InvocableMethod(label='Charge Stripe Customer')
        global static List<ResponseData> chargeStripeCustomers(List<ChargeDetails> charges) {
        List<ResponseData> results = new List<ResponseData>();
        for (ChargeDetails charge : charges) {
            results.add(chargeStripeCustomer(charge));
        }
        return results;
    }

    global static ResponseData chargeStripeCustomer(ChargeDetails charge) {
        //Create Customer
        StripeCustomer customer = StripeCustomer.create(charge.token, charge.description);
        System.debug(customer);
        //Create Charge
        Map<String, String> properties = new Map<String, String>{
            'currency' => charge.monetaryUnit
        };
        StripeCharge.create(customer.id, charge.amount, properties, null);
        //StripeCustomer.updateSubscription(customer.id, 'ANNUAL_SUBSCRIPTION');

        // Update the existing account to include the Stripe Customer ID
        Account a = [ SELECT Id, OwnerId, Name FROM Account WHERE Id=:charge.accountId ];
        a.StripeCustomerID__c = customer.id;
        update a;

        ResponseData data = new ResponseData();
        data.status = 'success';

        return data;
    }

  global class ChargeDetails {
    @InvocableVariable
    public String token;
    @InvocableVariable
    public String description;
    @InvocableVariable
    public Decimal amount;
    @InvocableVariable
    public String accountId;
    @InvocableVariable
    public String monetaryUnit;
  }

  global class ResponseData {
    @InvocableVariable
    public String status;
    @InvocableVariable
    public String errorMessage;
  }
}