import { CustomerModel } from "./CustomerModel";
import { OrderModel } from "./OrderModel";

export class CreateOrderRequest {
    customerDetails: CustomerModel;
    orderDetails: OrderModel;
    redirectionUrl:string;
  
    constructor(customerDetails: CustomerModel, orderDetails: OrderModel,redirectionUrl:string) {
      this.customerDetails = customerDetails;
      this.orderDetails = orderDetails;
      this.redirectionUrl=redirectionUrl
    }
  
    setCustomerDetails(customerDetails: CustomerModel): void {
      this.customerDetails = customerDetails;
    }
  
    setOrderDetails(orderDetails: OrderModel): void {
      this.orderDetails = orderDetails;
    }
  }