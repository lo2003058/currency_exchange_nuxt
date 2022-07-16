<template>
  <v-card>
    <v-card-title>Latest Exchange</v-card-title>
    <v-card-text>
      <v-autocomplete
        v-model="base"
        :items="symbolsList"
        outlined
        dense
        label="Base"
        @change="fetchCurrency(base)"
        :disabled="loading"
      ></v-autocomplete>
      <div v-if="items.length > 0">
        <p>DateTime: {{ exchangeDate }}</p>
        <v-data-table
          :headers="headers"
          :items="items"
          item-key="symbol"
          :items-per-page="10"
          class="elevation-1"
        >
        </v-data-table>
      </div>
    </v-card-text>
  </v-card>
</template>

<script>
import moment from "moment";
import _ from "lodash";

export default {
  name: "latestExchangeComponent",
  props: {
    headers: Array,
    symbolsList: Array,
  },
  data() {
    return {
      loading: false,
      exchangeDate: null,
      base: null,
      items: [],
    }
  },
  methods: {
    fromParent(value) {
      this.base = value;
      this.fetchCurrency(value);
    },

    async fetchCurrency(symbols) {
      this.loading = true;
      this.$axios.setHeader('apikey', process.env.FOREIGN_EXCHANGE_API_KEY)

      try {
        const tempLatestItems = [];
        const tempRawLatestExchange = await this.$axios.$get(process.env.FOREIGN_EXCHANGE_API_URL + "latest?base=" + symbols);
        this.exchangeDate = moment.unix(tempRawLatestExchange.timestamp).format('DD-MM-YYYY, HH:mm:ss');
        _.forEach(tempRawLatestExchange.rates, function (value, key) {
          tempLatestItems.push({
            symbol: key,
            rate: value,
          });
        });
        this.items = tempLatestItems;
      } catch (e) {
        alert(e.message);
      }

      this.loading = false;
    },

  },
}
</script>

<style scoped>

</style>
