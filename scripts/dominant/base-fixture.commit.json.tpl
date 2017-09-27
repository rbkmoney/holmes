{"ops": [

    {"insert": {"object": {"globals": {
        "ref": {},
        "data": {
            "party_prototype": {"id": 42},
            "providers": {"value": [{"id": 1}, {"id": 2}, {"id": 3}, {"id": 4}]},
            "system_account_set": {"value": {"id": 1}},
            "external_account_set": {"value": {"id": 1}},
            "inspector": {"value": {"id": 1}},
            "default_contract_template": {"id": 2},
            "common_merchant_proxy": {"id": 1000}
        }
    }}}},

    {"insert": {"object": {"system_account_set": {
        "ref": {"id": 1},
        "data": {
            "name": "Primary",
            "description": "Primary",
            "accounts": [
                {"key": {"symbolic_code": "RUB"}, "value": {
                    "settlement": $(${CURDIR}/create-account.sh RUB $*)
                }}
            ]
        }
    }}}},

    {"insert": {"object": {"external_account_set": {
        "ref": {"id": 1},
        "data": {
            "name": "Primary",
            "description": "Primary",
            "accounts": [
                {"key": {"symbolic_code": "RUB"}, "value": {
                    "income": $(${CURDIR}/create-account.sh RUB $*),
                    "outcome": $(${CURDIR}/create-account.sh RUB $*)
                }}
            ]
        }
    }}}},

    {"insert": {"object": {"party_prototype": {
        "ref": {"id": 42},
        "data": {
            "shop": {
                "shop_id": "TEST",
                "category": {"id": 1},
                "currency": {"symbolic_code": "RUB"},
                "details": {"name": "SUPER DEFAULT SHOP"},
                "location": {"url": ""}
            },
            "contract": {
                "contract_id": "TEST",
                "test_contract_template": {"id": 1},
                "payout_tool": {
                    "payout_tool_id": "TEST",
                    "payout_tool_info": {"bank_account": {
                        "account": "01234567890123456789",
                        "bank_name": "TEST BANK",
                        "bank_post_account": "01234567890123456789",
                        "bank_bik": "123456789"
                    }},
                    "payout_tool_currency": {"symbolic_code": "RUB"}
                }
            }
        }
    }}}},

    {"insert": {"object": {"inspector": {
        "ref": {"id": 1},
        "data": {
            "name": "Kovalsky",
            "description": "World famous inspector Kovalsky at your service!",
            "proxy": {
                "ref": {"id": 100},
                "additional": {
                    "risk_score": "high"
                }
            }
        }
    }}}},

    {"insert": {"object": {"term_set_hierarchy": {
        "ref": {"id": 1},
        "data": {
            "term_sets": [
                {
                    "action_time": {},
                    "terms": {
                        "payments": {
                            "currencies": {"value": [
                                {"symbolic_code": "RUB"}
                            ]},
                            "categories": {"value": [
                                {"id": 1}
                            ]},
                            "payment_methods": {"value": [
                                {"id": {"bank_card": "visa"}},
                                {"id": {"bank_card": "mastercard"}},
                                {"id": {"bank_card": "nspkmir"}},
                                {"id": {"payment_terminal": "euroset"}}
                            ]},
                            "cash_limit": {"decisions": [
                                {
                                    "if_": {"condition": {"currency_is": {"symbolic_code": "RUB"}}},
                                    "then_": {"value": {
                                        "lower": {"inclusive": {"amount": 1000, "currency": {"symbolic_code": "RUB"}}},
                                        "upper": {"exclusive": {"amount": 4200000, "currency": {"symbolic_code": "RUB"}}}
                                    }}
                                }
                            ]},
                            "fees": {"decisions": [
                                {
                                    "if_": {"condition": {"currency_is": {"symbolic_code": "RUB"}}},
                                    "then_": {"value": [
                                        {
                                            "source": {"merchant": "settlement"},
                                            "destination": {"system": "settlement"},
                                            "volume": {"share": {"parts": {"p": 45, "q": 1000}, "of": "payment_amount"}}
                                        }
                                    ]}
                                }
                            ]},
                            "holds": {
                                "payment_methods": {"value": [
                                    {"id": {"bank_card": "visa"}},
                                    {"id": {"bank_card": "mastercard"}}
                                ]},
                                "lifetime": {"value": {"seconds": 3}}
                            },
                            "refunds": {
                                "payment_methods": {"value": [
                                    {"id": {"bank_card": "visa"}},
                                    {"id": {"bank_card": "mastercard"}}
                                ]},
                                "fees": {"value": [
                                ]}
                            }
                        }
                    }
                }
            ]
        }
    }}}},

    {"insert": {"object": {"term_set_hierarchy": {
        "ref": {"id": 2},
        "data": {
            "parent_terms" : {"id": 1},
            "term_sets": [
                {
                    "action_time": {},
                    "terms": {
                        "payments": {
                            "categories": {"value": [
                                {"id": 2}
                            ]}
                        }
                    }
                }
            ]
        }
    }}}},

    {"insert": {"object": {"contract_template": {
        "ref": {"id": 1},
        "data": {
            "terms": {"id": 1}
        }
    }}}},

    {"insert": {"object": {"contract_template": {
        "ref": {"id": 2},
        "data": {
            "terms": {"id": 2}
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

    {"insert": {"object": {"category": {
        "ref": {"id": 1},
        "data": {
            "name": "Basic test category",
            "description": "Basic test category for mocketbank provider",
            "type": "test"
        }
    }}}},

    {"insert": {"object": {"category": {
        "ref": {"id": 2},
        "data": {
            "name": "Quasi-live test category",
            "description": "Quasi-live test category for mocketbank provider",
            "type": "live"
        }
    }}}},

    {"insert": {"object": {"category": {
        "ref": {"id": 3},
        "data": {
            "name": "Pastry VTB24",
            "description": "Items of food consisting of sweet pastry with a cream, jam, or fruit filling (only VTB24 clients should enjoy it)",
            "type": "live"
        }
    }}}},

    {"insert": {"object": {"category": {
        "ref": {"id": 4},
        "data": {
            "name": "Pastry TCS",
            "description": "Items of food consisting of sweet pastry with a cream, jam, or fruit filling (only TCS clients should enjoy it)",
            "type": "live"
        }
    }}}},

    {"insert": {"object": {"payment_method": {
        "ref": {"id": {"bank_card": "visa"}},
        "data": {
            "name": "VISA",
            "description": "VISA bank cards"
        }
    }}}},

    {"insert": {"object": {"payment_method": {
        "ref": {"id": {"bank_card": "mastercard"}},
        "data": {
            "name": "Mastercard",
            "description": "Mastercard bank cards"
        }
    }}}},

    {"insert": {"object": {"payment_method": {
        "ref": {"id": {"bank_card": "maestro"}},
        "data": {
            "name": "Maestro",
            "description": "Maestro bank cards"
        }
    }}}},

    {"insert": {"object": {"payment_method": {
        "ref": {"id": {"bank_card": "nspkmir"}},
        "data": {
            "name": "НСПК Мир",
            "description": "НСПК Мир"
        }
    }}}},

    {"insert": {"object": {"payment_method": {
        "ref": {"id": {"payment_terminal": "euroset"}},
        "data": {
            "name": "Евросеть",
            "description": "Оплата через терминалы Евросеть"
        }
    }}}},

    {"insert": {"object": {"provider": {
        "ref": {"id": 1},
        "data": {
            "name": "Mocketbank",
            "description": "Mocketbank",
            "terminal": {"value": [
                {"id": 1}
            ]},
            "proxy": {
                "ref": {"id": 1},
                "additional": {}
            },
            "abs_account": "0000000001",
            "terms": {
                "currencies": {"value": [
                    {"symbolic_code": "RUB"}
                ]},
                "categories": {"value": [
                    {"id": 1},
                    {"id": 2}
                ]},
                "payment_methods": {"value": [
                    {"id": {"bank_card": "visa"}},
                    {"id": {"bank_card": "mastercard"}},
                    {"id": {"bank_card": "maestro"}},
                ]},
                "cash_limit": {"value": {
                    "lower": {"inclusive": {"amount": 1000, "currency": {"symbolic_code": "RUB"}}},
                    "upper": {"exclusive": {"amount": 10000000, "currency": {"symbolic_code": "RUB"}}}
                }},
                "cash_flow": {"decisions": [
                    {
                        "if_": {"condition": {"payment_tool": {"bank_card": {"payment_system_is": "visa"}}}},
                        "then_": {"value": [
                            {
                                "source": {"provider": "settlement"},
                                "destination": {"merchant": "settlement"},
                                "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "payment_amount"}}
                            },
                            {
                                "source": {"system": "settlement"},
                                "destination": {"provider": "settlement"},
                                "volume": {"share": {"parts": {"p": 15, "q": 1000}, "of": "payment_amount"}}
                            }
                        ]}
                    },
                    {
                        "if_": {"condition": {"payment_tool": {"bank_card": {"payment_system_is": "mastercard"}}}},
                        "then_": {"value": [
                            {
                                "source": {"provider": "settlement"},
                                "destination": {"merchant": "settlement"},
                                "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "payment_amount"}}
                            },
                            {
                                "source": {"system": "settlement"},
                                "destination": {"provider": "settlement"},
                                "volume": {"share": {"parts": {"p": 18, "q": 1000}, "of": "payment_amount"}}
                            }
                        ]}
                    },
                    {
                        "if_": {"condition": {"payment_tool": {"bank_card": {"payment_system_is": "maestro"}}}},
                        "then_": {"value": [
                            {
                                "source": {"provider": "settlement"},
                                "destination": {"merchant": "settlement"},
                                "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "payment_amount"}}
                            },
                            {
                                "source": {"system": "settlement"},
                                "destination": {"provider": "settlement"},
                                "volume": {"share": {"parts": {"p": 19, "q": 1000}, "of": "payment_amount"}}
                            }
                        ]}
                    }
                ]},
                "holds": {
                    "lifetime": {"value": {"seconds": 3600}}
                },
                "refunds": {
                    "cash_flow": {"value": [
                        {
                            "source": {"merchant": "settlement"},
                            "destination": {"provider": "settlement"},
                            "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "payment_amount"}}
                        }
                    ]}
                }
            },
            "accounts": [
                {"key": {"symbolic_code": "RUB"}, "value": {
                    "settlement": $(${CURDIR}/create-account.sh RUB $*)
                }}
            ]
        }
    }}}},

    {"insert": {"object": {"provider": {
        "ref": {"id": 2},
        "data": {
            "name": "Tinkoff Credit Systems",
            "description": "Tinkoff Credit Systems",
            "terminal": {"value": [
                {"id": 2}
            ]},
            "proxy": {
                "ref": {"id": 2},
                "additional": {}
            },
            "abs_account": "1000000001",
            "terms": {
                "currencies": {"value": [
                    {"symbolic_code": "RUB"}
                ]},
                "categories": {"value": [
                    {"id": 4}
                ]},
                "payment_methods": {"value": [
                    {"id": {"bank_card": "visa"}},
                    {"id": {"bank_card": "mastercard"}}
                ]},
                "cash_limit": {"value": {
                    "lower": {"inclusive": {"amount": 1000, "currency": {"symbolic_code": "RUB"}}},
                    "upper": {"exclusive": {"amount": 10000000, "currency": {"symbolic_code": "RUB"}}}
                }},
                "cash_flow": {"decisions": [
                    {
                        "if_": {"condition": {"payment_tool": {"bank_card": {"payment_system_is": "visa"}}}},
                        "then_": {"value": [
                            {
                                "source": {"provider": "settlement"},
                                "destination": {"merchant": "settlement"},
                                "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "payment_amount"}}
                            },
                            {
                                "source": {"system": "settlement"},
                                "destination": {"provider": "settlement"},
                                "volume": {"share": {"parts": {"p": 14, "q": 1000}, "of": "payment_amount"}}
                            }
                        ]}
                    },
                    {
                        "if_": {"condition": {"payment_tool": {"bank_card": {"payment_system_is": "mastercard"}}}},
                        "then_": {"value": [
                            {
                                "source": {"provider": "settlement"},
                                "destination": {"merchant": "settlement"},
                                "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "payment_amount"}}
                            },
                            {
                                "source": {"system": "settlement"},
                                "destination": {"provider": "settlement"},
                                "volume": {"share": {"parts": {"p": 17, "q": 1000}, "of": "payment_amount"}}
                            }
                        ]}
                    }
                ]}
            },
            "accounts": [
                {"key": {"symbolic_code": "RUB"}, "value": {
                    "settlement": $(${CURDIR}/create-account.sh RUB $*)
                }}
            ]
        }
    }}}},

    {"insert": {"object": {"provider": {
        "ref": {"id": 3},
        "data": {
            "name": "VTB24",
            "description": "VTB24",
            "terminal": {"value": [
                {"id": 3}
            ]},
            "proxy": {
                "ref": {"id": 3},
                "additional": {}
            },
            "abs_account": "1000000002",
            "terms": {
                "currencies": {"value": [
                    {"symbolic_code": "RUB"}
                ]},
                "categories": {"value": [
                    {"id": 3}
                ]},
                "payment_methods": {"value": [
                    {"id": {"bank_card": "nspkmir"}}
                ]},
                "cash_limit": {"value": {
                    "lower": {"inclusive": {"amount": 1000, "currency": {"symbolic_code": "RUB"}}},
                    "upper": {"exclusive": {"amount": 10000000, "currency": {"symbolic_code": "RUB"}}}
                }},
                "cash_flow": {"value": [
                    {
                        "source": {"provider": "settlement"},
                        "destination": {"merchant": "settlement"},
                        "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "payment_amount"}}
                    },
                    {
                        "source": {"system": "settlement"},
                        "destination": {"provider": "settlement"},
                        "volume": {"share": {"parts": {"p": 23, "q": 1000}, "of": "payment_amount"}}
                    }
                ]}
            },
            "accounts": [
                {"key": {"symbolic_code": "RUB"}, "value": {
                    "settlement": $(${CURDIR}/create-account.sh RUB $*)
                }}
            ]
        }
    }}}},

    {"insert": {"object": {"provider": {
        "ref": {"id": 4},
        "data": {
            "name": "Euroset",
            "description": "Euroset",
            "terminal": {"value": [
                {"id": 4}
            ]},
            "proxy": {
                "ref": {"id": 4},
                "additional": {}
            },
            "abs_account": "1000000042",
            "terms": {
                "currencies": {"value": [
                    {"symbolic_code": "RUB"}
                ]},
                "categories": {"value": [
                    {"id": 2}
                ]},
                "payment_methods": {"value": [
                    {"id": {"payment_terminal": "euroset"}}
                ]},
                "cash_limit": {"value": {
                    "lower": {"inclusive": {"amount": 10000, "currency": {"symbolic_code": "RUB"}}},
                    "upper": {"exclusive": {"amount": 1000000, "currency": {"symbolic_code": "RUB"}}}
                }},
                "cash_flow": {"value": [
                    {
                        "source": {"provider": "settlement"},
                        "destination": {"merchant": "settlement"},
                        "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "payment_amount"}}
                    },
                    {
                        "source": {"system": "settlement"},
                        "destination": {"provider": "settlement"},
                        "volume": {"share": {"parts": {"p": 23, "q": 1000}, "of": "payment_amount"}}
                    }
                ]}
            },
            "accounts": [
                {"key": {"symbolic_code": "RUB"}, "value": {
                    "settlement": $(${CURDIR}/create-account.sh RUB $*)
                }}
            ]
        }
    }}}},

    {"insert": {"object": {"terminal": {
        "ref": {"id": 1},
        "data": {
            "name": "Mocketbank Test Acquiring",
            "description": "Mocketbank Test Acquiring",
            "risk_coverage": "high"
        }
    }}}},

    {"insert": {"object": {"terminal": {
        "ref": {"id": 2},
        "data": {
            "name": "TCS Acquiring",
            "description": "TCS Acquiring",
            "risk_coverage": "high"
        }
    }}}},

    {"insert": {"object": {"terminal": {
        "ref": {"id": 3},
        "data": {
            "name": "VTB24 НСПК Мир",
            "description": "VTB24 НСПК Мир",
            "risk_coverage": "high"
        }
    }}}},

    {"insert": {"object": {"terminal": {
        "ref": {"id": 4},
        "data": {
            "name": "Euroset",
            "description": "Терминал Евросеть для магазинов с боевой категорией",
            "risk_coverage": "high"
        }
    }}}},

    {"insert": {"object": {"proxy": {
        "ref": {"id": 1},
        "data": {
            "name": "Mocketbank Proxy",
            "description": "Mocked bank proxy for integration test purposes",
            "url": "http://${PROXY_MOCKETBANK}:${THRIFT_PORT}/proxy/mocketbank",
            "options": {}
        }
    }}}},

    {"insert": {"object": {"proxy": {
        "ref": {"id": 2},
        "data": {
            "name": "TCS Bank Proxy",
            "description": "TCS Bank Proxy",
            "url": "http://${PROXY_TINKOFF}:${THRIFT_PORT}/proxy/tinkoff",
            "options": {}
        }
    }}}},

    {"insert": {"object": {"proxy": {
        "ref": {"id": 3},
        "data": {
            "name": "VTB24 Bank Proxy",
            "description": "VTB24 Bank Proxy",
            "url": "http://${PROXY_VTB}:${THRIFT_PORT}/proxy/vtb",
            "options": {}
        }
    }}}},

    {"insert": {"object": {"proxy": {
        "ref": {"id": 4},
        "data": {
            "name": "Euroset Proxy",
            "description": "Agent Proxy Euroset",
            "url": "http://${PROXY_AGENT}:${THRIFT_PORT}/proxy/agent",
            "options": {}
        }
    }}}},

    {"insert": {"object": {"proxy": {
        "ref": {"id": 100},
        "data": {
            "name": "Mocket Inspector Proxy",
            "description": "Mocked inspector proxy for integration test purposes",
            "url": "http://${PROXY_MOCKET_INSPECTOR}:${THRIFT_PORT}/proxy/mocket/inspector",
            "options": {"risk_score": "high"}
        }
    }}}}
]}
