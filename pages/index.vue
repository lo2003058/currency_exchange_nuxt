<template>
  <v-container>
    <v-card>
      <v-tabs
        v-model="tab"
        grow
        centered
      >
        <v-tab v-for="(title,index) in titleLists" :key="index">
          {{ title }}
        </v-tab>
      </v-tabs>
      <v-tabs-items v-model="tab">
        <v-tab-item>
          <LatestExchangeComponent
            :headers="headers"
            :symbols-list="symbolsList"
            ref="latest"
          ></LatestExchangeComponent>
        </v-tab-item>
        <v-tab-item>
          <HistoryExchangeRateComponent
            :headers="headers"
            :symbols-list="symbolsList"
            @findLatest="callChildFetch"
          ></HistoryExchangeRateComponent>
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
      titleLists: ["Latest", "History"],
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
    // this.fetchSymbols();
  },
  methods: {
    callChildFetch(value) {
      this.tab = 0;
      this.$refs.latest.fromParent(value);
    },
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
