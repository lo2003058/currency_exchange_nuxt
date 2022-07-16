<template>
  <v-card>
    <v-card-title>History Exchange Rate</v-card-title>
    <v-card-text>
      <v-row>
        <v-col>
          <v-menu
            v-model="menu"
            :close-on-content-click="false"
            :nudge-right="40"
            transition="scale-transition"
            offset-y
            min-width="auto"
          >
            <template v-slot:activator="{ on, attrs }">
              <v-text-field
                v-model="start_at"
                label="Start date"
                readonly
                outlined
                dense
                v-bind="attrs"
                v-on="on"
              ></v-text-field>
            </template>
            <v-date-picker
              v-model="start_at"
              :min="minDate"
              :max="maxDate"
              @input="menu = false"
              @change="fetchCurrency(base,start_at, end_at)"
            ></v-date-picker>
          </v-menu>
        </v-col>
        <v-col>
          <v-menu
            v-model="menu2"
            :close-on-content-click="false"
            :nudge-right="40"
            transition="scale-transition"
            offset-y
            min-width="auto"
          >
            <template v-slot:activator="{ on, attrs }">
              <v-text-field
                v-model="end_at"
                label="End date"
                outlined
                dense
                readonly
                v-bind="attrs"
                v-on="on"
              ></v-text-field>
            </template>
            <v-date-picker
              v-model="end_at"
              :min="minDate"
              :max="maxDate"
              @input="menu2 = false"
              @change="fetchCurrency(base,start_at, end_at)"
            ></v-date-picker>
          </v-menu>
        </v-col>
        <v-col>
          <v-autocomplete
            v-model="base"
            :items="symbolsList"
            outlined
            dense
            label="Base"
            @change="fetchCurrency(base,start_at, end_at)"
            :disabled="loading"
          ></v-autocomplete>
        </v-col>
      </v-row>
      <div v-if="rawHistoryExchange.rates">
        <v-chip
          class="mr-2 mb-2"
          @click="getHistoryExchangeByDate(date)"
          v-for="(date,index) in dateLists"
          :key="index"
        >
          {{ date }}
        </v-chip>
        <div v-if="items.length > 0">
          <v-divider class="mb-2"/>
          <v-data-table
            :headers="headers"
            :items="items"
            item-key="symbol"
            :items-per-page="10"
            class="elevation-1"
          >
            <template v-slot:item.symbol="{ item }">
              <v-chip @click="findLatest(item.symbol)">
                {{ item.symbol }}
              </v-chip>
            </template>
          </v-data-table>
        </div>
      </div>
    </v-card-text>
  </v-card>
</template>

<script>
import moment from "moment";
import _ from "lodash";

export default {
  name: "historyExchangeRateComponent",
  props: {
    headers: Array,
    symbolsList: Array,
  },
  data() {
    return {
      maxDate: moment().format("YYYY-MM-DD"),
      minDate: moment().subtract(365, "days").format("YYYY-MM-DD"),
      menu: false,
      menu2: false,
      loading: false,
      base: null,
      rawHistoryExchange: [],
      items: [],
      dateLists: [],
      start_at: null,
      end_at: null,
    }
  },
  methods: {
    findLatest(base) {
      this.$emit('findLatest', base);
    },

    getHistoryExchangeByDate(date) {
      const tempHistoryItems = [];
      if (this.rawHistoryExchange) {
        _.forEach(this.rawHistoryExchange.rates[date], function (value, key) {
          tempHistoryItems.push({
            symbol: key,
            rate: value,
          });
        });
      }
      this.items = tempHistoryItems;
    },

    validator(symbols, start_at, end_at) {
      if (start_at && end_at) {
        if (moment(start_at).isSameOrBefore(end_at)) {
          return !!symbols;
        } else {
          this.start_at = null;
          this.end_at = null;
          alert("Start day not greater than end day!");
        }
      }
      return false;
    },

    async fetchCurrency(symbols, start_at, end_at) {
      this.loading = true;
      this.$axios.setHeader('apikey', process.env.FOREIGN_EXCHANGE_API_KEY)
      try {
        if (this.validator(symbols, start_at, end_at)) {
          const tempHistoryDateLists = [];
          const tempRawHistoryExchange = await this.$axios.$get(process.env.FOREIGN_EXCHANGE_API_URL + "timeseries?base=" + symbols + "&start_date=" + start_at + "&end_date=" + end_at);
          this.rawHistoryExchange = tempRawHistoryExchange;
          _.forEach(tempRawHistoryExchange.rates, function (value, key) {
            tempHistoryDateLists.push(key);
          });
          this.dateLists = tempHistoryDateLists;
        }
      } catch (e) {
        console.log(e.message);
      }
      this.loading = false;
    },
  }
}
</script>

<style scoped>

</style>
