# Service for managing the invoices.
@App.service 'MnoeInvoices', (MnoeApiSvc) ->
  _self = @

  @currentBillingAmount = () ->
    MnoeApiSvc.all('invoices').customGET('current_billing_amount')

  @lastInvoicingAmount = () ->
    MnoeApiSvc.all('invoices').customGET('last_invoicing_amount')

  @outstandingAmount = () ->
    MnoeApiSvc.all('invoices').customGET('outstanding_amount')

  return @
