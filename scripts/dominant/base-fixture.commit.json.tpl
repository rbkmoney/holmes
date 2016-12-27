{"ops": [
    {"insert": {"object": {"globals": {
        "ref": {},
        "data": {
            "party_prototype": {"id": 42},
            "providers": {"value": [{"id": 1}, {"id": 2}, {"id": 3}]},
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
    {"insert": {"object": {"category": {
        "ref": {"id": 2},
        "data": {
            "name": "Integration test category",
            "description": "Goods sold by category providers",
            "type": "test"
        }
    }}}},
    {"insert": {"object": {"provider": {
        "ref": {"id": 1},
        "data": {
            "name": "Brovider",
            "description": "A provider but bro",
            "terminal": {"value": [{"id": 1}, {"id": 2}]},
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
            "terminal": {"value": [{"id": 3}]},
            "proxy": {
                "ref": {"id": 2},
                "additional": {"override": "Drovider"}
            }
        }
    }}}},
    {"insert": {"object": {"provider": {
        "ref": {"id": 3},
        "data": {
            "name": "Mocketbank",
            "description": "Mocketbank",
            "terminal": {"value": [{"id": 4}, {"id": 5}, {"id": 6}]},
            "proxy": {
                "ref": {"id": 3},
                "additional": {}
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
            "payment_method": {"id": {"bank_card": "mastercard"}},
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
                    "volume": {"share": {"parts": {"p": 17, "q": 1000}, "of": "payment_amount"}}
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
    {"insert": {"object": {"terminal": {
        "ref": {"id": 3},
        "data": {
            "name": "Drominal 1",
            "description": "Drominal 1",
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
                    "volume": {"share": {"parts": {"p": 15, "q": 1000}, "of": "payment_amount"}}
                }
            ],
            "accounts": {
                "currency": {"symbolic_code": "RUB"},
                "receipt": $(${CURDIR}/create-account.sh RUB $*),
                "compensation": $(${CURDIR}/create-account.sh RUB $*)
            },
            "options": {"override": "Drominal 1"}
        }
    }}}},
    {"insert": {"object": {"terminal": {
        "ref": {"id": 4},
        "data": {
            "name": "Drominal 4",
            "description": "Drominal 4",
            "payment_method": {"id": {"bank_card": "visa"}},
            "category": {"id": 2},
            "cash_flow": [
                {
                    "source": {"party": "provider", "designation": "receipt"},
                    "destination": {"party": "merchant", "designation": "general"},
                    "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "payment_amount"}}
                },
                {
                    "source": {"party": "system", "designation": "compensation"},
                    "destination": {"party": "provider", "designation": "compensation"},
                    "volume": {"share": {"parts": {"p": 15, "q": 1000}, "of": "payment_amount"}}
                }
            ],
            "accounts": {
                "currency": {"symbolic_code": "RUB"},
                "receipt": $(${CURDIR}/create-account.sh RUB $*),
                "compensation": $(${CURDIR}/create-account.sh RUB $*)
            },
            "options": {}
        }
    }}}},
    {"insert": {"object": {"terminal": {
        "ref": {"id": 5},
        "data": {
            "name": "Drominal 5",
            "description": "Drominal 5",
            "payment_method": {"id": {"bank_card": "mastercard"}},
            "category": {"id": 2},
            "cash_flow": [
                {
                    "source": {"party": "provider", "designation": "receipt"},
                    "destination": {"party": "merchant", "designation": "general"},
                    "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "payment_amount"}}
                },
                {
                    "source": {"party": "system", "designation": "compensation"},
                    "destination": {"party": "provider", "designation": "compensation"},
                    "volume": {"share": {"parts": {"p": 15, "q": 1000}, "of": "payment_amount"}}
                }
            ],
            "accounts": {
                "currency": {"symbolic_code": "RUB"},
                "receipt": $(${CURDIR}/create-account.sh RUB $*),
                "compensation": $(${CURDIR}/create-account.sh RUB $*)
            },
            "options": {}
        }
    }}}},
    {"insert": {"object": {"terminal": {
        "ref": {"id": 6},
        "data": {
            "name": "Drominal 6",
            "description": "Drominal 6",
            "payment_method": {"id": {"bank_card": "maestro"}},
            "category": {"id": 2},
            "cash_flow": [
                {
                    "source": {"party": "provider", "designation": "receipt"},
                    "destination": {"party": "merchant", "designation": "general"},
                    "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "payment_amount"}}
                },
                {
                    "source": {"party": "system", "designation": "compensation"},
                    "destination": {"party": "provider", "designation": "compensation"},
                    "volume": {"share": {"parts": {"p": 15, "q": 1000}, "of": "payment_amount"}}
                }
            ],
            "accounts": {
                "currency": {"symbolic_code": "RUB"},
                "receipt": $(${CURDIR}/create-account.sh RUB $*),
                "compensation": $(${CURDIR}/create-account.sh RUB $*)
            },
            "options": {}
        }
    }}}},
    {"insert": {"object": {"proxy": {
        "ref": {"id": 1},
        "data": {
            "url": "http://proxy-tinkoff:8022/proxy/tinkoff",
            "options": []
        }
    }}}},
    {"insert": {"object": {"proxy": {
        "ref": {"id": 2},
        "data": {
            "url": "http://proxy-vtb:8022/proxy/vtb",
            "options": []
        }
    }}}},
    {"insert": {"object": {"proxy": {
        "ref": {"id": 3},
        "data": {
            "url": "http://proxy-mocketbank:8022/proxy/mocketbank",
            "options": []
        }
    }}}}
]}
