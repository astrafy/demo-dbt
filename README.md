# dbt demo

This repository is a playground to learn how to use dbt and to test new features. It contains
two dbt projects:
- dbt/jaffle_shop: the famous jaffle shop data product from dbt labs. The repository has evolved from the original
code you will find on the official dbt labs github page as we have extended with new features,
packages, macros, etc.
- dbt/dim_modelling: playground project for dimensional modelling. This is inspired from this [article](https://docs.getdbt.com/blog/kimball-dimensional-model)

This repository is not linked to a Gitlab CI pipeline on purpose as goal is to experiment
quickly.

## Quickstart

1. Create a python virtual environment in python 3.10.5 named "venv_dbt_demo" by following the
instruction on this [Gitbook page](https://astrafy.gitbook.io/technical-cookbook/python/local-development/python-setup-pyenv)

2. Install the required dependencies by running the following at the root of the repo:
```
poetry install
```

3. Assign the dbt profiles from this repository by running the following commands:
```
cd dbt
dbt_profile_assign $(pwd)
```
You need to have the function defined in your .zshrc profile. You can find instructions on this
[Gitbook page](https://astrafy.gitbook.io/data/dbt/configuration)

4. Activate your Google Cloud account by running the following command:
```
gcloud-activate default
```
You need to have the function defined in your .zshrc profile. You can find instructions on this
[Gitbook page](https://astrafy.gitbook.io/google-cloud/configuration/authentication)

You also need to have initialized beforehand gcloud with a default account. You can do this by running
the following command:
```
gcloud init
```

5. You also need to go to `macros/db_ds_tbl_id_generator` and replace all with your own project ids.

6. You are now ready to run dbt commands within the dbt repository. You should start with the
'jaffle_shop' example and then the 'dim_modelling'.

This dbt project comes with two targets:

- **sbx** target: it will materialize the models in the sandbox datasets with your $USER prepended to the table names (either file name or alias defined in config)
- **prd** target: it will materialize the models in the prd datasets with the vanilla table names (either file name or alias defined in config)

## Features

### Unit Tests

Unit tests are defined in YAML files located within the `/models` directory. In this repository, unit tests are available in the `jaffle_shop` directory, specifically at `jaffle_shop/models/intermediate/int_dim_customers.yml`.

To run unit tests, use the following command:

```sh
dbt test --select test_type:unit
```

### dbt --empty flag

The --empty flag in dbt limits the rows returned by ref and source functions to zero. This allows dbt to execute the model SQL against the target data warehouse without performing expensive reads of input data.

To use this flag, use the following command:

```sh
dbt run --select stg_customers --empty
```

### Elementary Anomaly Detection
Elementary allows you to configure and execute data tests just like native dbt tests. These tests help monitor specific metrics, such as row count, null rate, and average value, to detect significant changes and deviations.

The anomaly detection tests configuration is defined in .yml files in your dbt project, just like in native dbt tests.

Here is an example of volume anomalies test in the model `orders`:

```yml
tests:
    - elementary.volume_anomalies:
        timestamp_column: "order_date"
        anomaly_sensitivity: 2
        anomaly_direction: "both"
        detection_period:
        period: day
        count: 7
        training_period:
        period: day
        count: 30
        ignore_small_changes:
        spike_failure_percent_threshold: 0.01
```

To run this test, run the following command:

```sh
dbt test --select orders
```