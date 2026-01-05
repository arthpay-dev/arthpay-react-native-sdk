export class CustomerModel {
  firstName: string = '';
  lastName: string = '';
  chAddrStreet: string = '';
  chAddrCity: string = '';
  chAddrState: string = '';
  chAddrZip: string = '';
  chEmail: string = '';
  chMobile: string = '';

  setFirstName(firstName: string): void {
    this.firstName = firstName;
  }

  setLastName(lastName: string): void {
    this.lastName = lastName;
  }

  setChAddrStreet(street: string): void {
    this.chAddrStreet = street;
  }

  setChAddrCity(city: string): void {
    this.chAddrCity = city;
  }

  setChAddrState(state: string): void {
    this.chAddrState = state;
  }

  setChAddrZip(zipCode: string): void {
    this.chAddrZip = zipCode;
  }

  setChEmail(email: string): void {
    this.chEmail = email;
  }

  setChMobile(mobileNo: string): void {
    this.chMobile = mobileNo;
  }
}
