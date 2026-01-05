export class OrderModel {
  orderInfo: string = '';
  currency: string = '';
  amount: string = '';

  setOrderInfo(orderInfo: string): void {
    this.orderInfo = orderInfo;
  }

  setCurrency(currency: string): void {
    this.currency = currency;
  }

  setAmount(amount: string): void {
    this.amount = amount;
  }
}
