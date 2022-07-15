<template>
  <v-container>
    <v-card>
      <v-tabs v-model="tab" grow>
        <v-tab v-for="(title,index) in titleLists" :key="index">
          {{ title }}
        </v-tab>
      </v-tabs>
      <v-tabs-items v-model="tab">
        <v-tab-item>
          <LatestExchangeComponent :headers="headers" :symbols-list="symbolsList"></LatestExchangeComponent>
        </v-tab-item>
        <v-tab-item>
          <HistoryExchangeRateComponent :headers="headers" :symbols-list="symbolsList"></HistoryExchangeRateComponent>
        </v-tab-item>
      </v-tabs-items>
    </v-card>
  </v-container>
</template>

<script>
import _ from "lodash";

export default {
  name: 'index',
  data() {
    return {
      titleLists: ["Latest Exchange", "History Exchange Rate"],
      headers: [
        {
          text: 'Symbol',
          align: 'start',
          sortable: true,
          value: 'symbol',
        },
        {
          text: 'Rate',
          align: 'start',
          sortable: true,
          value: 'rate',
        },
      ],
      symbolsList: [],
      tab: null,
    }
  },
  mounted() {
    this.fetchSymbols();
  },
  methods: {
    async fetchSymbols() {
      this.loading = true;
      this.$axios.setHeader('apikey', process.env.FOREIGN_EXCHANGE_API_KEY)

      try {
        const tempSymbols = await this.$axios.$get(process.env.FOREIGN_EXCHANGE_API_URL + "symbols");
        const tempSymbolsList = [];
        _.forEach(tempSymbols.symbols, function (value, key) {
          tempSymbolsList.push(key);
        });
        this.symbolsList = tempSymbolsList;
      } catch (e) {
        console.log(e.message);
      }

      this.loading = false;
    }
  }
}
</script>
