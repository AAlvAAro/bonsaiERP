# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module AccountsHelper
  def with_payment(al)
    if al.payment
      txt = ntc(al.payment_amount) + ' + ' + ntc(al.payment_interests_penalties)

      link_to(txt, "/payments/#{al.payment_id}/transaction", :title => 'Cantidad + intereses/penalidades')
    end
  end

  # Creates a link to the transaction if exists
  def link_description(al)
    if al.transaction_id
      link_to al.description, al.transaction
    elsif al.account_ledger_id
      link_to al.description, "/account_ledgers/#{al.account_ledger_id}"
    else
      al.description
    end
  end

  # links to the correct account for account_ledger
  def link_account(al)
    case al.account_type
    when"Bank" then link_to "Bancos", al.account
    when"CashRegister" then link_to "Cajas", al.account
    end
  end

  # Creates for income or outcome title
  def account_ledger_title(klass)
    if klass.income?
      "<span class='dark_green'>ingreso</span>".html_safe
    else
      "<span class='red'>egreso</span>".html_safe
    end
  end


  def account_ledger_contact_label(klass)
    if klass.income?
      "Cliente"
    else
      "Proveedor"
    end
  end


  def account_ledger_contact_collection(klass)
    if klass.income?
      Client.org
    else
      Supplier.org
    end
  end

  def pluralize_conciliation(klass)
    if klass.account_ledgers.pendent.size == 1
      "1 conciliación pendiente"
    else
      "#{klass.account_ledgers.pendent.size} conciliaciones pendientes"
    end
  end

  def link_pendent_ledgers(klass)
    link_to( "Conciliaciones pendientes (#{klass.account_ledgers.pendent.size})", "#{polymorphic_url(klass)}?option=false") if klass.account_ledgers.pendent.any?
  end
end
