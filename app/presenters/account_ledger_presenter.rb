# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedgerPresenter < BasePresenter
  presents :account_ledger

  def null_link
    h.link_to "Anular", account_ledger, :class => 'delete', 'data-confirm' => 'Esta seguro de borrar la transacción' if account_ledger.can_destroy?
  end

end
