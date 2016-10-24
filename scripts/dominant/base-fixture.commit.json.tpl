{"ops": [
    {"insert": {"object": {"globals": {
        "ref": {},
        "data": {
            "party_prototype": {"id": 42},
            "providers": {"value": [{"id": 1}, {"id": 2}]},
            "system_accounts": {"value": [{"id": 1}]}
        }
    }}}},
    {"insert": {"object": {"system_account_set": {
        "ref": {"id": 1},
        "data": {
            "name": "Primary",
            "description": "Primary",
            "currency": {"symbolic_code": "RUB"},
            "compensation": $(${CURDIR}/create-account.sh RUB $*)
        }
    }}}},
    {"insert": {"object": {"party_prototype": {
        "ref": {"id": 42},
        "data": {
            "shop": {
                "category": {"id": 1},
                "currency": {"symbolic_code": "RUB"},
                "details": {"name": "SUPER DEFAULT SHOP"}
            },
            "default_services": {
                "payments": {
                    "domain_revision": 0,
                    "terms": {"id": 1}
                }
            }
        }
    }}}},
    {"insert": {"object": {"payments_service_terms": {
        "ref": {"id": 1},
        "data": {
            "payment_methods": {"value": [
                {"id": {"bank_card": "visa"}},
                {"id": {"bank_card": "mastercard"}},
                {"id": {"bank_card": "nspkmir"}}
            ]},
            "limits": {"predicates": [
                {
                    "if_": {"condition": {"currency_is": {"symbolic_code": "RUB"}}},
                    "then_": {"value": {
                        "min": {"inclusive": 1000},
                        "max": {"exclusive": 4200000}
                    }}
                },
                {
                    "if_": {"condition": {"currency_is": {"symbolic_code": "USD"}}},
                    "then_": {"value": {
                        "min": {"inclusive": 200},
                        "max": {"exclusive": 313370}
                    }}
                }
            ]},
            "fees": {"predicates": [
                {
                    "if_": {"condition": {"currency_is": {"symbolic_code": "RUB"}}},
                    "then_": {"value": [
                        {
                            "source": {"party": "merchant", "designation": "general"},
                            "destination": {"party": "system", "designation": "compensation"},
                            "volume": {"share": {"parts": {"p": 45, "q": 1000}, "of": "payment_amount"}}
                        }
                    ]}
                },
                {
                    "if_": {"condition": {"currency_is": {"symbolic_code": "USD"}}},
                    "then_": {"value": [
                        {
                            "source": {"party": "merchant", "designation": "general"},
                            "destination": {"party": "system", "designation": "compensation"},
                            "volume": {"share": {"parts": {"p": 65, "q": 1000}, "of": "payment_amount"}}
                        }
                    ]}
                }
            ]}
        }
    }}}},
    {"insert": {"object": {"currency": {
        "ref": {"symbolic_code": "RUB"},
        "data": {
            "name": "Russian rubles",
            "numeric_code": 643,
            "symbolic_code": "RUB",
            "exponent": 2
        }
    }}}},
    {"insert": {"object": {"currency": {
        "ref": {"symbolic_code": "USD"},
        "data": {
            "name": "US Dollars",
            "numeric_code": 840,
            "symbolic_code": "USD",
            "exponent": 2
        }
    }}}},
    {"insert": {"object": {"category": {
        "ref": {"id": 1},
        "data": {
            "name": "Categories",
            "description": "Goods sold by category providers",
            "type": "test"
        }
    }}}},
    {"insert": {"object": {"provider": {
        "ref": {"id": 1},
        "data": {
            "name": "Brovider",
            "description": "A provider but bro",
            "terminal": {"value": [{"id": 1}]},
            "proxy": {
                "ref": {"id": 1},
                "additional": {"override": "Brovider"}
            }
        }
    }}}},
    {"insert": {"object": {"provider": {
        "ref": {"id": 2},
        "data": {
            "name": "Drovider",
            "description": "Well, a drovider",
            "terminal": {"value": [{"id": 2}]},
            "proxy": {
                "ref": {"id": 2},
                "additional": {"override": "Drovider"}
            }
        }
    }}}},
    {"insert": {"object": {"terminal": {
        "ref": {"id": 1},
        "data": {
            "name": "Brominal 1",
            "description": "Brominal 1",
            "payment_method": {"id": {"bank_card": "visa"}},
            "category": {"id": 1},
            "cash_flow": [
                {
                    "source": {"party": "provider", "designation": "receipt"},
                    "destination": {"party": "merchant", "designation": "general"},
                    "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "payment_amount"}}
                },
                {
                    "source": {"party": "system", "designation": "compensation"},
                    "destination": {"party": "provider", "designation": "compensation"},
                    "volume": {"share": {"parts": {"p": 18, "q": 1000}, "of": "payment_amount"}}
                }
            ],
            "accounts": {
                "currency": {"symbolic_code": "RUB"},
                "receipt": $(${CURDIR}/create-account.sh RUB $*),
                "compensation": $(${CURDIR}/create-account.sh RUB $*)
            },
            "options": {"override": "Brominal 1"}
        }
    }}}},
    {"insert": {"object": {"terminal": {
        "ref": {"id": 2},
        "data": {
            "name": "Brominal 2",
            "description": "Brominal 2",
            "payment_method": {"id": {"bank_card": "nspkmir"}},
            "category": {"id": 1},
            "cash_flow": [
                {
                    "source": {"party": "provider", "designation": "receipt"},
                    "destination": {"party": "merchant", "designation": "general"},
                    "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "payment_amount"}}
                },
                {
                    "source": {"party": "system", "designation": "compensation"},
                    "destination": {"party": "provider", "designation": "compensation"},
                    "volume": {"share": {"parts": {"p": 14, "q": 1000}, "of": "payment_amount"}}
                }
            ],
            "accounts": {
                "currency": {"symbolic_code": "RUB"},
                "receipt": $(${CURDIR}/create-account.sh RUB $*),
                "compensation": $(${CURDIR}/create-account.sh RUB $*)
            },
            "options": {"override": "Brominal 2"}
        }
    }}}},
    {"insert": {"object": {"proxy": {
        "ref": {"id": 1},
        "data": {
            "url": "http://tinkoff-proxy:8022/proxy/tinkoff",
            "options": []
        }
    }}}},
    {"insert": {"object": {"proxy": {
        "ref": {"id": 2},
        "data": {
            "url": "http://vtb-proxy:8022/proxy/vtb",
            "options": []
        }
    }}}}
]}
