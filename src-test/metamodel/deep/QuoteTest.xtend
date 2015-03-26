package metamodel.deep

import metamodel.deep.MetaModelDeep
import metamodel.Deep

//@MetaModelDeep
class Quote {
	String name
	double price
	@Deep()
	Address address

	static class Address {
	}
}
